local function highlight(ref)
  tes3.createVisualEffect({ magicEffectId = tes3.effect.light, reference = ref })

  local sceneNode = ref.object.sceneNode
  for node in table.traverse(sceneNode.children) do
      if node:isInstanceOfType(ni.type.NiTriShape) then
          if node.name == 'Editable Mesh' then
            -- book nodes are weird
            return
          end

          -- node doesn't always have material property!
          if node.materialProperty then
            node.materialProperty.emissive = { r = 0.5, g = 0.5, b = 0.5 }
          end
      end
  end
end

local function unhighlight(ref, current)
  if (ref and current) and (ref.object.id == current.object.id) then
    return
  end

  tes3.removeVisualEffect({ reference = ref })

  if ref.name == 'Editable Mesh' then
    -- book nodes are weird
    return
  end

  local sceneNode = ref.object.sceneNode
  for node in table.traverse(sceneNode.children) do
      if node:isInstanceOfType(ni.type.NiTriShape) then
          if node.materialProperty then
            local sameNodeInPrevious = nil
            local isSameNodeInPrevious = nil
            if current then
              sameNodeInPrevious = current.object.sceneNode:getObjectByName(node.name)
              if sameNodeInPrevious then
                -- compare only if both are not nil
                isSameNodeInPrevious = (sameNodeInPrevious or node) and sameNodeInPrevious.parent.name == node.parent.name
              end
            end
            
          
            if not isSameNodeInPrevious then
              -- do not unhighlight if this node exists on current object as well
              node.materialProperty.emissive = { r = 0, g = 0, b = 0 }
            end                 
          end
      end
  end
end

local function activateCallback(e)
  if e.target and (e.target.object.objectType == tes3.objectType.npc) then
    return
  end
  unhighlight(e.target)
end
event.register(tes3.event.activate, activateCallback)

local function onActivationTargetChanged(e)
  if e.current and (e.current.object.objectType == tes3.objectType.npc) then
    return
  end

  if e.current then
      highlight(e.current)
   end
   if e.previous then
      unhighlight(e.previous, e.current)
   end
end
event.register("activationTargetChanged", onActivationTargetChanged)

local function OnInitialized()
  mwse.log("[Highlighter] lua script loaded")
end
event.register("initialized", OnInitialized)
