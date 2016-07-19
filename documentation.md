#MUContext

__Properties__

    MTLDevice device
    MTLCommandQueue queue
    MTLCommandBuffer commandbuffer
    MTLLibrary library

__Functions__
  
    (instancetype) init
    (MUResourceManager) newResourceManager
    (MUComputeManager) newComputeManagerForFunction(NSString name)
  
##MUResourceManager

__Properties__

    MUContext context
    NSMutableDictionary resources

__Functions__

    (instancetype) init
    (bool)newTextureFromFile:(NSString file) atIndex(idx)
    (bool)attachTexture:(MTLTexture tx) atIndex(idx)

##MUComputeManager

__Properties__

    MUContext context
    MTLComputeCommandEncoder encoder
    MTLComputePipelineState pipeline

__Functions__

    (instancetype) init
    (bool) setResourcesFromManager(MUResourceManager manager)
    (bool) setCompletionHandler(block)
    (bool) dispatch
    (bool) dispatchAndDestroy
    (bool) destroy

##MUShaderManager

__Properties__

    MUContext context

__Functions__
  
    (instancetype) init
  
