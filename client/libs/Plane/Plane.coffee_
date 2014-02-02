class @Plane
    constructor: ({parent, @ownMatrix}) ->
        # todo: I want to have named parameters with default values, how???
        @ownMatrix ?= new WebKitCSSMatrix()
        @transformQueue = []
        @_parent = parent 

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
        m3d = new WebKitCSSMatrix(@ownMatrix)   
        discardUpTo = 0
        for i, o of @transformQueue
            factor = o.ease (now - o.start - o.delay) / o.duration
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
                @ownMatrix = m3d 
                discardUpTo = +i+1
        
        @transformQueue = @transformQueue.slice discardUpTo

        if @parent?
            @parent.absoluteMatrix().multiply m3d
        else 
            m3d
    do: (o) -> 
        # o.translate
        # o.rotate
        # o.around

        o.duration ?= 1000
        o.delay ?= 0
        o.ease ?= d3.ease("cubic-in-out")
        o.start ?= +new Date()

        @transformQueue.push o
        @