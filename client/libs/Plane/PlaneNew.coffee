class @Plane
    duration: (n) -> @transform.duration = n; @
    delay: (n) -> @transform.delay = n; @
    ease: (n) -> @transform.ease = n; @
    
    translateX: (x) -> @transform.translate.x = x; @
    translateY: (y) -> @transform.translate.y = y; @
    translateZ: (z) -> @transform.translate.z = z; @
    translateXY: (x,y) -> $.extend(@transform.translate, {x:x, y:y ? x}); @
    translateXZ: (x,z) -> $.extend(@transform.translate, {x:x, z:z ? x}); @
    translateYZ: (y,z) -> $.extend(@transform.translate, {y:y, z:z ? y}); @
    translate: (x,y,z) -> $.extend(@transform.translate, {x:x, y:y ? x, z:z ? y ? x}); @

    rotateX: (x) -> @transform.rotate.x = x; @
    rotateY: (y) -> @transform.rotate.y = y; @
    rotateZ: (z) -> @transform.rotate.z = z; @
    rotateXY: (x,y) -> $.extend(@transform.rotate, {x:x, y:y ? x}); @
    rotateXZ: (x,z) -> $.extend(@transform.rotate, {x:x, z:z ? x}); @
    rotateYZ: (y,z) -> $.extend(@transform.rotate, {y:y, z:z ? y}); @
    rotate: (x,y,z) -> $.extend(@transform.rotate, {x:x, y:y ? x, z:z ? y ? x}); @

    aroundX: (x) -> @transform.around.x = x; @
    aroundY: (y) -> @transform.around.y = y; @
    aroundZ: (z) -> @transform.around.z = z; @
    aroundXY: (x,y) -> $.extend(@transform.around, {x:x, y:y ? x}); @
    aroundXZ: (x,z) -> $.extend(@transform.around, {x:x, z:z ? x}); @
    aroundYZ: (y,z) -> $.extend(@transform.around, {y:y, z:z ? y}); @
    around: (x,y,z) -> $.extend(@transform.around, {x:x, y:y ? x, z:z ? y ? x}); @
    
    scaleX: (x) -> @transform.scale.x = x; @
    scaleY: (y) -> @transform.scale.y = y; @
    scaleZ: (z) -> @transform.scale.z = z; @
    scaleXY: (x,y) -> $.extend(@transform.scale, {x:x, y:y ? x}); @
    scaleXZ: (x,z) -> $.extend(@transform.scale, {x:x, z:z ? x}); @
    scaleYZ: (y,z) -> $.extend(@transform.scale, {y:y, z:z ? y}); @
    scale: (x,y,z) -> $.extend(@transform.scale, {x:x, y:y ? x, z:z ? y ? x}); @
    
    skewX: (x) -> @transform.skew.x = x; @
    skewY: (y) -> @transform.skew.y = y; @
    skewXY: (x,y) -> $.extend(@transform.skew, {x:x, y:y ? x}); @
    
    identityTransform: -> {
        rotate: {x:0,y:0,z:0}
        scale: {x:1,y:1,z:1}
        skew: {x:0,y:0}
        translate: {x:0,y:0,z:0}
        around: {x:0,y:0,z:0}
        duration : 1000
        delay : 0
        ease : d3.ease("cubic-in-out")
    }
        # unmatrix new WebKitCSSMatrix()


    constructor: ({parent, @m3d, @width, @height, @resolution}) ->
        # todo: I want to have named parameters with default values, how???
        @m3d ?= new WebKitCSSMatrix()
        @transformQueue = []
        @_parent = parent 

        # {rotate:{x:0,y:0,z:0},scale:{x:1,y:1,z:1},skew:{x:0,y:0},translate:{x:0,y:0,z:0}}
        @transform = @identityTransform()
        @translateXY("-50%")

    Object.defineProperties @prototype,
        parent:
            get: -> @_parent
            set: (newParent) ->                
                # Steps I'm taking to animate the change of parent CS (Plane):
                # 1: Compute our current real world coordinates (the absolute transform oldM3d)
                # 2: Change the parent Plane 
                #      (note that now our real world coordinates changed newM3d)
                # 3: Find the transform (newM3d_to_oldM3d) that leaves us in exactly the same position 
                #    we were before even though our Plane is now relative to a different parent (newParent)
                #    and apply it instantaneously.
                #    Now we are exactly were we started, but our transform is relative to the new parent
                # 4: Compute oldM3d_to_newM3d (by inverting newM3d_to_oldM3d), decompose it in its primitive 
                #       transforms (rotations, translations, etc) and interpolate those
                # 5: IT WORKED!!!!! HOW COOL!!!!! 
                
                oldM3d = @absoluteMatrix()
                @_parent = newParent
                newM3d = @absoluteMatrix()
                
                # from newM3d to oldM3d
                newM3d_to_oldM3d = newM3d.inverse().multiply oldM3d
                
                t = unmatrix(newM3d_to_oldM3d)
                t.duration = 0
                this.do t

                oldM3d_to_newM3d = newM3d_to_oldM3d.inverse()
                t = unmatrix(oldM3d_to_newM3d)
                t.duration = 1000;
                this.do t

                @_parent
               
    absoluteMatrix: ->      
        # todo: learn how to code properly in coffescript and make this mess readable 
        # todo: "now" should be the frame timestamp, not the date timestamp, 
        #       but we are not in requestanimationframe :(
        # todo: optimization merge all consecutive complete transforms (not only thouse in the head of the queue)
        #       
        now = +new Date() 
        m3d = new WebKitCSSMatrix(@m3d)
        discardUpTo = 0
        for i, o of @transformQueue
            factor = o.ease (now - o.start) / o.duration
            if o.translate?
                # todo: how to put every func parameter in its own line?
                m3d = m3d.translate (o.translate.x ? 0) * factor, (o.translate.y ? 0) * factor, (o.translate.z ? 0) * factor
            if o.around?
                m3d = m3d.translate o.around.x ? 0, o.around.y ? 0, o.around.z ? 0
            if o.rotate? 
                # m3d = m3d.rotate (o.rotate.x ? 0) * factor, (o.rotate.y ? 0) * factor, (o.rotate.z ? 0) * factor
                m3d = m3d.rotate 0, 0, (o.rotate.z ? 0) * factor
                m3d = m3d.rotate 0, (o.rotate.y ? 0) * factor, 0
                m3d = m3d.rotate (o.rotate.x ? 0) * factor, 0, 0
            if o.around?
                m3d = m3d.translate -o.around.x ? 0, -o.around.y ? 0, -o.around.z ? 0
            
            if o.skew?
                m3d = m3d.skewX (o.skew.x ? 0) * factor
                m3d = m3d.skewY (o.skew.y ? 0) * factor
            
            if o.scale?
                m3d = m3d.scale o.scale.x ? 1, o.scale.y ? 1, o.scale.z ? 1

            if discardUpTo == +i and factor == 1
                @m3d = m3d 
                discardUpTo = +i+1
        
        @transformQueue = @transformQueue.slice discardUpTo

        if @parent?
            @parent.absoluteMatrix().multiply m3d
        else 
            m3d
    
    do: () -> 
        for name, xyz of @transform
            for axis, value of xyz
                if typeof value == "string" and value.slice(-1) == "%"
                    xyz[axis] = switch axis
                        when "x" then parseFloat(value) / 100 * @width 
                        when "y" then parseFloat(value) / 100 * @height 
                        when "z" then 0   
        
        
        @transform.start ?= +new Date()
        @transform.start += @transform.delay
              
        @transformQueue.push @transform
        @transform = @identityTransform()
        
        @