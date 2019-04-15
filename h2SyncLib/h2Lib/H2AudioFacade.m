//
//  AudioFacade.m
//
//  Created by JasonChuang on 9/12/12.
//

#import "H2AudioFacade.h"
#import "H2DebugHeader.h"
#import "h2CmdInfo.h"
#import "H2Config.h"

#import "VirtualRingBuffer.h"

// BLE
#import "H2BleEquipId.h"
#import "H2BleService.h"
#import "H2BleCentralManager.h"




/************************************
 * Application specific parameters
 ************************************/

//#define DECDEBUG
//#define DECDEBUGBYTE

#define FOUR_BYTES_PER_FRAME 4  // associated with kAudioFormatFlagsAudioUnitCanonical
#define AMPLITUDE (1<<24)
//#define AMPLITUDE (1<<16)

//#define OUTPUT_SAMPLE_RATE  96000.0f
#define OUTPUT_SAMPLE_RATE          48000.0f
#define INPUT_SAMPLE_RATE           48000.0f

#define THRESHOLD               0
#define DIV_NUM                 16

#define LONG_PERIOD             38
#define SHORT_PERIOD            23

typedef enum {
    IDLE = 0,
	STARTBIT = 1,
	SAMEBIT  = 2,
	NEXTBIT  = 3,
	STOPBIT  = 4,
	DECODE   = 5
} uart_state_t;

Float32 audioRawValue[] =
{
    0.000000-9070447*1.3,         // phase 0, val =
    9070447.772869 * 1.3,   // phase 1, val =
    15261092.466574,  // phase 2, val =
    16606448.131868,  // phase 3, val =
    12679373.850849,  // phase 4, val =
    4726687.960361,   // phase 5, val =
    -4726687.960361,  // phase 6, val =
    -12679373.850849, // phase 7, val =
    -16606448.131868, // phase 8, val =
    -15261092.466574, // phase 9, val =
    -9070447.772869 * 1.3 // phase 10, val =
};


BOOL fSendHigh = 0;
uint8_t sendBit = 0;
UInt8 dataTransfer = 0;

static UInt8 *txBuffer;
static UInt16 txLength;
static UInt16 txTargetLength;

// TODO: 64KB should be enough, but 128KB is better
#define RING_BUFFER_SIZE 131072

/**
 Internal usage only
 */

@interface H2AudioFacade() {
    VirtualRingBuffer __strong *_txBytes;
}

@property(readwrite) BOOL running;
@property(nonatomic, readwrite) AudioComponentInstance audioUnit;
@property(nonatomic, strong) VirtualRingBuffer *inputSamples;

- (void)processSamples;
- (BOOL)h2ResendCommand;

@end


/**
 This callback is called when new audio data from the microphone is available.
 */
static OSStatus RecordInput(void *inRefCon, 
                            AudioUnitRenderActionFlags *ioActionFlags, 
                            const AudioTimeStamp *inTimeStamp,
                            UInt32 inBusNumber, 
                            UInt32 inNumberFrames, 
                            AudioBufferList *ioData)
{
	// Get the code generator out of the audio controller
	H2AudioFacade *THIS = (__bridge H2AudioFacade *)inRefCon;

	// Because of the way our audio format (setup below) is chosen:
	// we only need 1 buffer, since it is mono
	// Samples are 32 bits = 4 bytes
	// 1 frame includes only 1 sample
	AudioBuffer buffer;

	buffer.mNumberChannels = 1;
	buffer.mDataByteSize = inNumberFrames * FOUR_BYTES_PER_FRAME;

    //  To know how many frames coming this time, actually it's 1020 to 1024 bytes for our settings.
    //    DLog(@"%ld", sourceBuffer.mDataByteSize);
    void *writePointer;     // used to store the writePoiner of the ring buffer
    
    if ([[THIS inputSamples] lengthAvailableToWriteReturningPointer:&writePointer] >= buffer.mDataByteSize) {
        buffer.mData = writePointer;
        // Put buffer in a AudioBufferList
        AudioBufferList bufferList;
        bufferList.mNumberBuffers = 1;
        bufferList.mBuffers[0] = buffer;

        // Then:
        // Obtain recorded samples
        OSStatus status;
        
        status = AudioUnitRender(THIS.audioUnit,
                                 ioActionFlags,
                                 inTimeStamp,
                                 inBusNumber,
                                 inNumberFrames,
                                 &bufferList);
        NSCAssert1(status == noErr, @"Error rendering input unit: %d", status);

        // copy incoming audio data to temporary buffer
        [[THIS inputSamples] didWriteLength:buffer.mDataByteSize];
        [THIS performSelectorOnMainThread:@selector(processSamples) withObject:nil waitUntilDone:NO];

        return noErr;
    }
#ifdef DEBUG_AUDIO
    DLog(@"No room for %u bytes", (unsigned int)buffer.mDataByteSize);
#endif
    // FIXME: should return some error code 
    return noErr;
}

/**
 This callback is called when the audioUnit needs new data to play through the speakers.
 If you don't have any, just don't write anything in the buffers
 */
static OSStatus RenderOutput(void *inRefCon, 
                             AudioUnitRenderActionFlags *ioActionFlags,
                             const AudioTimeStamp       *inTimeStamp,
                             UInt32                     inBusNumber,
                             UInt32                     inNumberFrames,
                             AudioBufferList            *ioData)
{
#if 1
    static long leftPhase;
    static long rightPhase;    // remember the phase to make the power wave smooth
    static long parityTx;
#else
    static NSInteger leftPhase;
    static NSInteger rightPhase;    // remember the phase to make the power wave smooth
    static NSInteger parityTx;
#endif
    // Notes: ioData contains buffers (may be more than one!)
    // Fill them up as much as you can. Remember to set the size value in each buffer to match how
    // much data is in the buffer.
	
	// Get the code generator out of the audio controller
	H2AudioFacade *THIS = (__bridge H2AudioFacade *)inRefCon;

#if 0
    long channel;
    long *buffer;
#else
	NSInteger channel;
	SInt32 *buffer;
#endif

    /************************************
     *  Right channel is used to power the gadget
     ************************************/
//j    float divider = [THIS rightDivider];
    
    channel = 1;
    buffer = (SInt32 *)ioData->mBuffers[channel].mData;
//j    buffer = (long *)ioData->mBuffers[channel].mData;
    // indicate how much data we would write in the buffer
    ioData->mBuffers[channel].mDataByteSize = inNumberFrames * FOUR_BYTES_PER_FRAME;
    
	// Generate the samples
#if 1
    if ([THIS powering])  {
        for (unsigned long frame = 0; frame < inNumberFrames; frame++)  {
            buffer[frame] = (SInt32)(AMPLITUDE * sin(2 * M_PI * rightPhase / DIV_NUM*2));
//            buffer[frame] = (long)(AMPLITUDE * sin(2 * M_PI * rightPhase / DIV_NUM*2));
            rightPhase++;
        }
    }
#else
    if ([THIS powering])  {
        for (UInt32 frame = 0; frame < inNumberFrames; frame++)  {
            buffer[frame] = (SInt32)(AMPLITUDE * sin(2 * M_PI * rightPhase / 8));
            rightPhase++;
        }
    }
#endif
    /************************************
     *  Left channel is used to send out the byte
     ************************************/

    channel = 0;
    buffer = (SInt32 *)ioData->mBuffers[channel].mData;
//    buffer = (long *)ioData->mBuffers[channel].mData;
    // indicate how much data we would write in the buffer
    ioData->mBuffers[channel].mDataByteSize = inNumberFrames * FOUR_BYTES_PER_FRAME;
	// Generate the samples

//j	for (UInt32 frame = 0; frame < inNumberFrames; frame++)
    for (unsigned long frame = 0; frame < inNumberFrames; frame++)
	{
        if(dataTransfer == 1){
//            for (int i = 0 ; i<11; i++) {
//                DLog(@"***********  index = %d, the value is %8X", i, (txBuffer[i]));
//            }
            if (leftPhase >= 0 && leftPhase <= 31+1) { // start bit
                buffer[frame] = (SInt32)(audioRawValue[leftPhase%11]);
//                DLog(@"%lu --- %x ---", frame, buffer[frame]);
            }else if(leftPhase >= 32+1 && leftPhase < 160+1){
                if(fSendHigh)
                    buffer[frame] =  (SInt32)(sin(2 * M_PI * (leftPhase-1) / DIV_NUM) * AMPLITUDE);
                else
                    buffer[frame] =  (SInt32)(- sin(2 * M_PI * (leftPhase-1) / DIV_NUM) * AMPLITUDE);
            }else if(leftPhase >= 160+1 && leftPhase < 176+1){ // parity
                if (parityTx & 0x01) {
                    buffer[frame] =  (SInt32)(sin(2 * M_PI * (leftPhase-1) / DIV_NUM) * AMPLITUDE);
                }else{
                    buffer[frame] =  (SInt32)(- sin(2 * M_PI * (leftPhase-1) / DIV_NUM) * AMPLITUDE);
                }
            }else{
                buffer[frame] =  (SInt32)(sin(2 * M_PI * (leftPhase-1) / DIV_NUM) * AMPLITUDE);
            }
        }else{
            buffer[frame] =  (SInt32)(sin(2 * M_PI * (leftPhase-1) / DIV_NUM) * AMPLITUDE);
        }
        if (leftPhase >= 255+1){
            leftPhase = 0;
            parityTx = 0;
            if (txLength != 0) {
                txLength--;
                dataTransfer = 1;
            }else{
                dataTransfer = 0;
            }
            
        } else {
            
            leftPhase++;
            if (leftPhase % DIV_NUM == 1 && leftPhase / DIV_NUM >= 2 &&
                leftPhase / DIV_NUM <= 9  && dataTransfer == 1) {
                sendBit = (leftPhase >> 4) - 2;
                fSendHigh  = (BOOL) ((*(txBuffer+txTargetLength-txLength-1) >> sendBit) & 0x01);
//                DLog(@"----- the phase %lu and bit is %d ------", leftPhase, fSendHigh);
                if (fSendHigh) {
                    parityTx ^= 0x01;
                }
            }
        }

	}

	return noErr;
}


@implementation H2AudioFacade

// public
@synthesize delegate = _delegate;
@synthesize sampling = _sampling;
@synthesize powering = _powering;
// TODO: test purpose only, should be REMOVED
@synthesize rightDivider = _divider;
// exposed to callbacks
@synthesize audioUnit = _audioUnit;
@synthesize inputSamples = _inputSamples;

- (BOOL)createAudioUnit:(NSError **)error
{
#define kOutputBus 0
#define kInputBus  1
    
	OSStatus status;
    
	// Configure the search parameters to find the default playback output unit
	// (called the kAudioUnitSubType_RemoteIO on iOS but
	// kAudioUnitSubType_DefaultOutput on Mac OS X)
	AudioComponentDescription desc;
	desc.componentType = kAudioUnitType_Output;
	desc.componentSubType = kAudioUnitSubType_RemoteIO;
	desc.componentFlags = 0;
	desc.componentFlagsMask = 0;
	desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
	// Get the default output component
	AudioComponent defaultOutput = AudioComponentFindNext(NULL, &desc);
	NSAssert(defaultOutput, @"Can't find default output");
    
	// Create a new unit based on this that we'll use for input and output
	status = AudioComponentInstanceNew(defaultOutput, &_audioUnit);
//	NSAssert1(_audioUnit, @"Error creating unit: %ld", status);
    NSAssert1(_audioUnit, @"Error creating unit: %d", status);
	
	// Enable IO for recording
	UInt32 flag = 1;
	status = AudioUnitSetProperty(_audioUnit,
								  kAudioOutputUnitProperty_EnableIO,
								  kAudioUnitScope_Input,
								  kInputBus,
								  &flag,
								  sizeof(flag));
	NSAssert1(status == noErr, @"Error enabling input unit: %d", status);
    
	// Enable IO for playback
	status = AudioUnitSetProperty(_audioUnit,
								  kAudioOutputUnitProperty_EnableIO,
								  kAudioUnitScope_Output,
								  kOutputBus,
								  &flag,
								  sizeof(flag));
	NSAssert1(status == noErr, @"Error enabling output unit: %d", status);
    
	// Set the common format to 8.24 fixed point, linear PCM
	AudioStreamBasicDescription audioFormat;
	audioFormat.mFormatID			= kAudioFormatLinearPCM;
#if 1
    audioFormat.mFormatFlags        = kAudioFormatFlagIsSignedInteger |
    kAudioFormatFlagsNativeEndian |
    kAudioFormatFlagIsPacked |
    kAudioFormatFlagIsNonInterleaved |
    (kAudioUnitSampleFractionBits <<
     kLinearPCMFormatFlagsSampleFractionShift);
#else
    audioFormat.mFormatFlags        = kAudioFormatFlagIsFloat |
    kAudioFormatFlagsNativeEndian |
    kAudioFormatFlagIsPacked |
    kAudioFormatFlagIsNonInterleaved;
#endif
	audioFormat.mFramesPerPacket	= 1;
	audioFormat.mBitsPerChannel		= FOUR_BYTES_PER_FRAME * 8;
	audioFormat.mBytesPerFrame		= FOUR_BYTES_PER_FRAME;
    // it's non interleaved
	audioFormat.mBytesPerPacket		= FOUR_BYTES_PER_FRAME * 1;
    audioFormat.mFormatFlags |= kAudioFormatFlagIsNonInterleaved;
    
	// Apply input format of single channel
	audioFormat.mChannelsPerFrame	= 1;
	audioFormat.mSampleRate			= INPUT_SAMPLE_RATE;
	status = AudioUnitSetProperty(_audioUnit,
								  kAudioUnitProperty_StreamFormat,
								  kAudioUnitScope_Output,
								  kInputBus,
								  &audioFormat,
								  sizeof(audioFormat));
	NSAssert1(status == noErr, @"Error setting input stream format: %d", status);
    
	// Apply output format of 2 channels
	audioFormat.mChannelsPerFrame	= 2;
	audioFormat.mSampleRate			= OUTPUT_SAMPLE_RATE;
	status = AudioUnitSetProperty(_audioUnit,
								  kAudioUnitProperty_StreamFormat,
								  kAudioUnitScope_Input,
								  kOutputBus,
								  &audioFormat,
								  sizeof(audioFormat));
	NSAssert1(status == noErr, @"Error setting output stream format: %d", status);
    
    
    
    
	// Set input callback
	AURenderCallbackStruct callbackStruct;
	callbackStruct.inputProc = RecordInput;
	callbackStruct.inputProcRefCon = (__bridge void *)self;
	status = AudioUnitSetProperty(_audioUnit,
								  kAudioOutputUnitProperty_SetInputCallback,
								  kAudioUnitScope_Global,
								  kInputBus,
								  &callbackStruct,
								  sizeof(callbackStruct));
	NSAssert1(status == noErr, @"Error setting input callback: %d", status);
	
	// Set output callback
	callbackStruct.inputProc = RenderOutput;
	callbackStruct.inputProcRefCon = (__bridge void *)self;
	status = AudioUnitSetProperty(_audioUnit,
								  kAudioUnitProperty_SetRenderCallback,
								  kAudioUnitScope_Global,
								  kOutputBus,
								  &callbackStruct,
								  sizeof(callbackStruct));
	NSAssert1(status == noErr, @"Error setting output callback: %d", status);
	
	// Disable buffer allocation for the recorder (optional - do this if we want to pass in our own)
	flag = 0;
	status = AudioUnitSetProperty(_audioUnit,
								  kAudioUnitProperty_ShouldAllocateBuffer,
								  kAudioUnitScope_Output,
								  kInputBus,
								  &flag,
								  sizeof(flag));   
    return TRUE;
}



/**
 Change this funtion to decide what is done with incoming audio data from the microphone.
 Right now we copy it to our own temporary buffer.
 */
- (void)processSamples
{
    SInt32 *readPointer;
    unsigned long inBytes;
    
    static uart_state_t decState = IDLE;

    static NSInteger diff = 0;

    NSInteger sample;
    NSInteger tmp = 0;
    static NSInteger lastSample = 1;

    static NSInteger bitNum;
    static NSInteger parityRx;
    static NSInteger phase2;
//    static NSInteger lastPhase2;
    static UInt8 uartByte;
    static NSInteger sss = 0;

    while ((inBytes = [_inputSamples lengthAvailableToReadReturningPointer:(void *)&readPointer])) {

        /************************************
         * UART Decoding
         ************************************/
#if 1
        for (int j = 0; j < inBytes / FOUR_BYTES_PER_FRAME; j++) {
            sample = (readPointer[j] < THRESHOLD) ? 0 : 1;
#ifdef DEBUGWAVE
            printf("%8ld, %8.0f\n", phase2, readPointer[j]);
#endif
#ifdef DECDEBUG2
            if(decState == DECODE)
                printf("%8ld, %8.0f\n", phase2, readPointer[j]);
#endif
            if (j < inBytes / FOUR_BYTES_PER_FRAME - 1) {
                tmp = (readPointer[j+1] < THRESHOLD) ? 0 : 1;
            }
            if (sample != lastSample && tmp == lastSample) {
                sample = lastSample;
            }
            phase2 += 1;
            /////////////////////////////////////////////////
            //
            if (sample != lastSample) {
                diff = phase2 ;
                
                switch (decState) {
                    case IDLE:
                        if (lastSample == 1 && sample == 0 && ( 10 < diff ) && (diff < 19))
                        {
                            // 300 us tone toggle, then waiting start bit
                            decState = STARTBIT;
                        }
                        break;
                        
                    case STARTBIT:
                        if (lastSample == 0 && ( SHORT_PERIOD < diff ) && (diff < LONG_PERIOD))
                        {
                            bitNum = 0;
                            parityRx = 0;
                            uartByte = 0;
                            decState = DECODE;
                            
                        } else {
                            decState = IDLE;
                        }
                        
                        break;
                        
                    case DECODE:
                        if (( SHORT_PERIOD < diff) && (diff < LONG_PERIOD) ) {
                            if (bitNum < 8) {
                                uartByte = ((uartByte >> 1) + (sss << 7));
                                bitNum += 1;
                                parityRx += sss;
#ifdef DECDEBUG
                                printf("Bit %d value %d diff %ld parity %d\n", bitNum, sss, diff, parityRx & 0x01);
#endif
                            } else if (bitNum == 8) {
                                // parity bit
                                if(sss != (parityRx & 0x01))
                                {
#ifdef DECDEBUGBYTE
                                    printf(" -- parity %d,  UartByte 0x%x\n", sss, uartByte);
#endif
                                    decState = IDLE;//STARTBIT;
                                    lastSample = 0;// jason
                                } else {
#ifdef DECDEBUG
                                    printf(" ++ good parity %d, UartByte 0x%x\n", sss, uartByte);
#endif
                                    
                                    bitNum += 1;
                                }
                                
                            } else {
                                // we should now have the stopbit
                                if (sss == 1) {
                                    // we have a new and valid byte!
#ifdef DECDEBUGBYTE
                                    printf(" ++ StopBit: %ld UartByte 0x%x\n", sss, uartByte);
#endif
                                    @autoreleasepool {
                                        //////////////////////////////////////////////
                                        // This is where we receive the byte!!!
                                        //////////////////////////////////////////////
                                        if ([self.delegate conformsToProtocol:@protocol(H2AudioFacadeDelegate)] &&
                                            [self.delegate respondsToSelector:@selector(receiveAudioData:)])  {
                                            [self.delegate receiveAudioData:uartByte];
                                            
                                        }
                                    }
                                } else {
                                    // not a valid byte.
#ifdef DECDEBUGBYTE
                                    printf(" -- StopBit: %ld UartByte %d\n", sss, uartByte);
#endif
                                }
                                decState = IDLE;
                            }
                        } else if (diff > LONG_PERIOD) {
#ifdef DECDEBUG
                            printf("diff too long %ld\n", diff);
#endif
                            decState = IDLE;
                        } else {
                            // don't update the phase as we have to look for the next transition
                            lastSample = sample;
                            sss = 1;
                            continue;
                        }
                        break;
                        
                    default:
                        break;
                }
                phase2 = 0;// jason
                sss = 0;
            }
            ///////////////////////////end
            

             lastSample = sample;
        }
#endif

        // skip the consumed bytes
        [_inputSamples didReadLength:inBytes];
    }
}

- (id)init
{
    if (self = [super init]) {
        DLog(@"AUDIO FACADE INIT ...");
        _running = FALSE;
        _sampling = TRUE;
        _powering = TRUE;
        _divider = 4.0f;
        txBuffer = malloc(sizeof(UInt8)*512);
    }    
    return self;
}

- (void)delloc
{
    AudioUnitUninitialize(_audioUnit);
    AudioComponentInstanceDispose(_audioUnit);

    self.inputSamples = nil;
}
+ (H2AudioFacade *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}
////////////////////////////////////////////////////////////////////////////////
//

- (BOOL)audioStart:(NSError **)error;
{
    OSErr err;
    
    if (!_audioUnit)
        if (![self createAudioUnit:error])
            return FALSE;
    
    err = AudioUnitInitialize(_audioUnit);
    NSAssert1(err == noErr, @"Error initializing unit: %d", err);
    
    if (!_inputSamples)
        _inputSamples = [[VirtualRingBuffer alloc] initWithLength:(RING_BUFFER_SIZE)];
    
    err = AudioOutputUnitStart(_audioUnit);
    NSAssert1(err == noErr, @"Error starting unit: %hd", err);
    _running = TRUE;
#ifdef DEBUG_AUDIO
    DLog(@"audio start ..........");
#endif
    return TRUE;
}


/**
 *  Checking if it's running
 */
- (BOOL)isRunning
{
    return _running;
}

/**********************************************************
 *  Checking if it's running
 **********************************************************/
- (BOOL)send:(const UInt8 *)data bytes:(int)count
{
    UInt8 *readPointer;
    
    if ([_txBytes lengthAvailableToReadReturningPointer:(void *)&readPointer] >= count) {
        memccpy(readPointer, (const void *)data, count, 1);
        return 0;
    }

    // TODO: some error code
    return -1;
}

- (NSInteger)bytesInQueue
{
    return 0;
}

- (BOOL)audioStop
{
    AudioOutputUnitStop(_audioUnit);
    _running = FALSE;
    AudioUnitUninitialize(_audioUnit);
    return 0;
}


#pragma mark - NORMAL SEND COMMAND
// alcor audio tx format 6 bytes
#define ALCFORMATLENGTHEX               (6+1)
- (BOOL)sendCommandDataEx:(unsigned char *)cmdSrc withCmdLength:(UInt16)cmdLength cmdType :(UInt16)type returnDataLength:(UInt8)returnLength mcuBufferOffSetAt:(UInt8)mcuBufferAt
{
    // 6 bytes
    // 0,1 : command type
    // 2,3 : cmmand length
    // 4   : read meter data length, maximun 255 bytes
    // 5   : buffer offset location
    // last byte: check sum
#ifdef DEBUG_AUDIO
    DLog(@"DEBUG_LIB Sending Command ...");
#endif
    if (cmdLength > (288-ALCFORMATLENGTHEX) || cmdLength == 0) {
        return NO;
    }
    
    for (UInt16 index =0; index < sizeof([H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer); index++) {
        [H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[index] = 0;
    }
    [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferIndex = 0;
    [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferState = BUFFERIDLE;
    [H2SyncSystemMessageInfo sharedInstance].systemSyncCmdAck = NO;
    
    // store command to global command structure
    if (type) { // BGM COMMAND
        [H2SyncMeterCommand sharedInstance].cmdMeterTypeId = type;
        [H2SyncMeterCommand sharedInstance].cmdLength = cmdLength;
        [H2SyncMeterCommand sharedInstance].cmdMeterDataLength = returnLength;
        [H2SyncMeterCommand sharedInstance].cmdMcuBufferOffsetAt = mcuBufferAt;
        
        memcpy([H2SyncMeterCommand sharedInstance].cmdData, cmdSrc, cmdLength);

#ifdef DEBUG_AUDIO
        for (int i = 0; i < [H2SyncMeterCommand sharedInstance].cmdLength; i++) {
            DLog(@" METER_DEBUG METER COMMAND BUFFER %02d, %02X ", i, [H2SyncMeterCommand sharedInstance].cmdData[i]);
        }
#endif
    }else{ // SYSTEM COMMAND
        [H2SyncSystemCommand sharedInstance].cmdSystemTypeId = type;
        [H2SyncSystemCommand sharedInstance].cmdLength = cmdLength;
        [H2SyncSystemCommand sharedInstance].cmdSystemDataLength = returnLength;
        [H2SyncSystemCommand sharedInstance].cmdMcuBufferOffsetAt = mcuBufferAt;

        memcpy([H2SyncSystemCommand sharedInstance].cmdData, cmdSrc, cmdLength);

#ifdef DEBUG_AUDIO
        for (int i = 0; i < [H2SyncSystemCommand sharedInstance].cmdLength; i++) {
            DLog(@" SYSTEM_DEBUG SYSTEM COMMAND BUFFER %02d, %02X ", i, [H2SyncSystemCommand sharedInstance].cmdData[i]);
        }
#endif
    }

    
    
    for (UInt16 i =0; i<288; i++) {
        *(txBuffer+i) = 0x00;
    }
    
    txLength = 0;//cmdLength+ALCFORMATLENGTHEX;
    txTargetLength = cmdLength+ALCFORMATLENGTHEX;
    
    memcpy((txBuffer+ALCFORMATLENGTHEX-1), cmdSrc, cmdLength);
    UInt16 audioLength;
    audioLength = cmdLength+ALCFORMATLENGTHEX-1;
    // command type .... do something

    memcpy(txBuffer, &type, 2);

    txBuffer[4] = returnLength;
    memcpy((txBuffer+5), &mcuBufferAt, 1);
    memcpy((txBuffer+2), &audioLength, 2);

    // check value
    for (UInt16 i = 0; i<audioLength; i++) {
        (*(txBuffer+cmdLength+ALCFORMATLENGTHEX-1)) ^= (*(txBuffer+i));
    }
#ifdef DEBUG_AUDIO
    for (int i = 0; i < 6; i++) {
        DLog(@" Command HEAD %02d, %02X ++++++++", i, txBuffer[i]);
    }
    DLog(@" ROCHE CRC %d %02X ++++++++", cmdLength+ALCFORMATLENGTHEX-1, txBuffer[cmdLength+ALCFORMATLENGTHEX-1]);
#endif
    
    if (type) { // BGM HEADER
        memcpy([H2SyncSystemMessageInfo sharedInstance].cmdBgmHeader, txBuffer, 6);
    }else{ // SYSTEM HEADER
        memcpy([H2SyncSystemMessageInfo sharedInstance].cmdSystemHeader, txBuffer, 6);
    }
    
    
    if ([H2AudioAndBleResendCfg sharedInstance].didNeedSaveRocheTypePreCmd) {
        [H2AudioAndBleCommand sharedInstance].cmdPreMethod = [H2AudioAndBleCommand sharedInstance].cmdMethod;
        [H2AudioAndBleResendCfg sharedInstance].resendPreCmdLength = cmdLength + ALCFORMATLENGTHEX;
        memcpy([H2AudioAndBleResendCfg sharedInstance].resendPreCmdHeaderData, txBuffer, [H2AudioAndBleResendCfg sharedInstance].resendPreCmdLength);
    }
    
    if ([H2BleService sharedInstance].isBleCable) {
        NSData *cmdData = [[NSData alloc] init];
        cmdData = [NSData dataWithBytes:txBuffer length:cmdLength+ALCFORMATLENGTHEX];
        [[H2BleCentralController sharedInstance] H2BTCableWriteTask:(NSData *)cmdData withCharacteristicSel:type];
    }else{
#ifdef DEBUG_AUDIO
        DLog(@"DEBUG_AUDIO DID COME TO HERE  DO NOTHING  --------- ");
#endif
    }

#ifdef DEBUG_AUDIO
        DLog(@"DEBUG_AUDIO FADE COMMAND END  %d ++++++++", txLength);
#endif
    return YES;
}


#pragma mark - RESEND COMMAND
- (BOOL)h2ResendSystemCommand
{
    [H2AudioAndBleResendCfg sharedInstance].resendCmdLength = [H2SyncSystemCommand sharedInstance].cmdLength;
    [H2AudioAndBleResendCfg sharedInstance].resendCmdType = [H2SyncSystemCommand sharedInstance].cmdSystemTypeId;
    [self h2ResendCommand];
    return YES;
}
- (BOOL)h2ResendMeterCommand
{
    [H2AudioAndBleResendCfg sharedInstance].resendCmdLength = [H2SyncMeterCommand sharedInstance].cmdLength;
    [H2AudioAndBleResendCfg sharedInstance].resendCmdType = [H2SyncMeterCommand sharedInstance].cmdMeterTypeId;
    [self h2ResendCommand];
    return YES;
}

- (BOOL)h2AudioTriggerCommand
{
#ifdef DEBUG_AUDIO
    DLog(@"AUDIO SEND COMMAND");
#endif
    txLength = txTargetLength;
#ifdef DEBUG_AUDIO
    DLog(@"DEBUG_AUDIO FADE START SEND COMMAND  %d ++++++++", txLength);
#endif
    return YES;
}

- (BOOL)h2ResendCommand
{
    
#ifdef DEBUG_AUDIO
    for (int i = 0; i<[H2AudioAndBleResendCfg sharedInstance].resendCmdLength+ALCFORMATLENGTHEX; i++) {
        DLog(@"DEBUG RESEND BUFFER index = %d, value = %02X",i, txBuffer[i]);
    }
#endif
    if ([H2BleService sharedInstance].isBleCable) {
        txLength = 0;
//        [[H2BleCentralController sharedInstance] h2BTCableSubscribeTask];
        NSData *cmdData = [[NSData alloc] init];
        cmdData = [NSData dataWithBytes:txBuffer length:[H2AudioAndBleResendCfg sharedInstance].resendCmdLength + ALCFORMATLENGTHEX];
        [[H2BleCentralController sharedInstance] H2BTCableWriteTask:(NSData *)cmdData withCharacteristicSel:[H2AudioAndBleResendCfg sharedInstance].resendCmdType];
    }else{
        // txLength not equal to 0, audio left channel Start transfer data
        txLength = [H2AudioAndBleResendCfg sharedInstance].resendCmdLength + ALCFORMATLENGTHEX;
    }
    return YES;
}

#pragma mark - SEND PRE METER COMMAND
- (BOOL)h2SendMeterPreCommand
{
    txLength = 0;
    UInt16 cmdLength = [H2AudioAndBleResendCfg sharedInstance].resendPreCmdLength;
    UInt16 type = 0;
#ifdef DEBUG_LIB
    DLog(@"BLE DEBUG -- ROCHE 1");
#endif
    memcpy(&type, [H2AudioAndBleResendCfg sharedInstance].resendPreCmdHeaderData, 2);
#ifdef DEBUG_AUDIO
    for (int i = 0; i<cmdLength; i++) {
        
        DLog(@"DEBUG PRE CMOMMND BUFFER index = %d, value = %02X and %02X", i, [H2AudioAndBleResendCfg sharedInstance].resendPreCmdHeaderData[i], txBuffer[i]);
    }
#endif
    if ([H2BleService sharedInstance].isBleCable) {
#ifdef DEBUG_LIB
        DLog(@"BLE DEBUG -- ROCHE 2");
#endif
        txLength = 0;
//        [[H2BleCentralController sharedInstance] h2BTCableSubscribeTask];
        NSData *cmdData = [[NSData alloc] init];
        cmdData = [NSData dataWithBytes:[H2AudioAndBleResendCfg sharedInstance].resendPreCmdHeaderData length:cmdLength];
        [[H2BleCentralController sharedInstance] H2BTCableWriteTask:(NSData *)cmdData withCharacteristicSel:type];
    }else{
#ifdef DEBUG_LIB
        DLog(@"BLE DEBUG -- ROCHE 3");
        
#endif
//        memcpy(txBuffer, [H2AudioAndBleResendCfg sharedInstance].resendPreCmdHeaderData, [H2AudioAndBleResendCfg sharedInstance].resendPreCmdLength);
        memcpy(txBuffer, [H2AudioAndBleResendCfg sharedInstance].resendPreCmdHeaderData, cmdLength);
#ifdef DEBUG_AUDIO
        for (int i = 0; i<cmdLength; i++) {
            
            DLog(@"DEBUG PRE CMOMMND BUFFER index = %d, value = %02X and %02X", i, [H2AudioAndBleResendCfg sharedInstance].resendPreCmdHeaderData[i], txBuffer[i]);
        }
#endif
        // txLength not equal to 0, audio left channel Start transfer data
        txLength = cmdLength;
    }
    return YES;
    
}



- (BOOL)isAudioBusy{
    return YES;
}

- (BOOL)commandStop{
    txLength = 0;
    dataTransfer = 0;
    return YES;
}

@end
