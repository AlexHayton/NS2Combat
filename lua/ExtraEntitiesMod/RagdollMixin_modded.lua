    

if Server then

    // to fix a bug where dead physic bodys where still there
    local originalRagdollMixinOnTag = RagdollMixin.OnTag
    function RagdollMixin:OnTag(tagName)
    
        originalRagdollMixinOnTag(self, tagName)
        
        if self.isaNpc and (not self.GetHasClientModel or not self:GetHasClientModel()) then        
            if tagName == "death_end" then            
                if self.bypassRagdoll then
                    DestroyEntitySafe(self)
                end
            end            
        end
        
    end
    
end
