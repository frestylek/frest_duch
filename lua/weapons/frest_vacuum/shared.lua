if ( SERVER ) then
AddCSLuaFile()
end
    SWEP.PrintName		= "Odkurzacz"
    SWEP.Author		= "frestylek"
    SWEP.Instructions	= ""
    SWEP.Category		= "[fStands] SCP"
    
    SWEP.Spawnable = true
    SWEP.AdminOnly = false
    
    SWEP.Primary.ClipSize = -1
    SWEP.Primary.DefaultClip = -1
    SWEP.Primary.Automatic = false
    SWEP.Primary.Ammo = "none"
    
    SWEP.Secondary.ClipSize	= -1
    SWEP.Secondary.DefaultClip = -1
    SWEP.Secondary.Automatic = false
    SWEP.Secondary.Ammo	= "none"
    
    SWEP.Slot			= 2
    SWEP.SlotPos			= 1
    SWEP.DrawAmmo			= false
    SWEP.DrawCrosshair		= true
    
    SWEP.ViewModelFOV		= 54
    SWEP.ViewModel = ""
    SWEP.WorldModel = "models/fstands/vacuum.mdl"
    SWEP.UseHands   		= false
    SWEP.Damage = 0

    
    function SWEP:Think()
        
    end
    
    function SWEP:Initialize()
        self:DrawShadow(false)
    end
    if CLIENT then
        local WorldModel = ClientsideModel(SWEP.WorldModel)
    
        -- Settings...
        WorldModel:SetSkin(1)
        WorldModel:SetNoDraw(true)
    
        function SWEP:DrawWorldModel()
            local _Owner = self:GetOwner()
    
            if (IsValid(_Owner)) then
                -- Specify a good position
                local offsetVec = Vector(3, -2.7, 0)
                local offsetAng = Angle(180, 0, 0)
                
                local boneid = _Owner:LookupBone("ValveBiped.Bip01_R_Hand") -- Right Hand
                if !boneid then return end
    
                local matrix = _Owner:GetBoneMatrix(boneid)
                if !matrix then return end
    
                local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
    
                WorldModel:SetPos(newPos)
                WorldModel:SetAngles(newAng)
                WorldModel:SetModelScale(0.5,0)
                WorldModel:SetupBones()
            else
                WorldModel:SetPos(self:GetPos())
                WorldModel:SetAngles(self:GetAngles())
            end
    
            WorldModel:DrawModel()
        end
    end

    function SWEP:Equip()
        self:Deploy()
    end

    function SWEP:Deploy()
        self:SetHoldType("pistol")
    end
    
    function SWEP:PrimaryAttack()
        if self:GetNextPrimaryFire() > CurTime() then return end
        self:SetNextPrimaryFire(CurTime() + 3)
        self:EmitSound("vacuum.wav")
        
        if SERVER then
            for k,v in ipairs(ents.FindInSphere(self:GetOwner():EyePos(),300)) do
                
                if !v:IsPlayer() then continue end
                    if v:HasWeapon("frest_duch") and v.State == 1 then
                        v:KillSilent()
                    end
            end
        end
    end
    
    function SWEP:DrawHUD()
   
    end
    
    function SWEP:Holster( wep )
            return true
    end
    
    function SWEP:SecondaryAttack()
        
    end
    
    function SWEP:Reload()
        
    end
    
    function SWEP:OnRemove()	
        
    end
    
    function SWEP:OnDrop()
        self:Remove()
    end