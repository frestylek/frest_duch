if ( SERVER ) then
AddCSLuaFile()
end
    SWEP.PrintName		= "SCP-9057"
    SWEP.Author		= "frestylek"
    SWEP.Instructions	= ""
    SWEP.Category		= "[fStands] SCP"
    
    SWEP.Spawnable = true
    SWEP.AdminOnly = false
    
    SWEP.Primary.ClipSize = -1
    SWEP.Primary.DefaultClip = -1
    SWEP.Primary.Automatic = true
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
            
    SWEP.tblcld = {}
    SWEP.tbl = {
        {		
            Nazwa = "Rozproszenie",
            opis = "Rozpraszasz się po pomieszczeniu",
            cld = 1,
            dur = 0,
            target = false,
            click = function(ply,dur,cld) 
                if ply.State == 2 then return end
                if CLIENT then
                    if IsValid(ply.p) then
                        ply.p:StopEmission(true)
                    end
                    ply.p = ply:CreateParticleEffect("duch2",0)
                    ply:SetColor(Color(255,255,255,0))
                    ply:SetModelScale(0,1)
                    ply.State = 2
                end
                if SERVER then
                    for k,v in ipairs(ply:GetWeapons()) do
                        if v:GetClass() == "frest_duch" then continue end
                        ply:StripWeapon(v:GetClass())
                    end
                    ply.State = 2
                    ply:SetSolid(SOLID_NONE)
                    ply:SetCustomCollisionCheck( true )
                    ply:SetSolid(SOLID_NONE)

                    ply:SetCollisionGroup( COLLISION_GROUP_WORLD )
                    ply:CollisionRulesChanged()
                    ply:SetModelScale(0,1)
                    ply.scp343noclip = true
                    ply:SetNoDraw(true)
                end
                ply:SetCustomCollisionCheck( true )
				ply:SetSolid(SOLID_NONE)
				ply:SetCollisionGroup( COLLISION_GROUP_WORLD )
				ply:CollisionRulesChanged()
                ply.scp343noclip = true
            end,
            reload = function(ply,dur,cld) 
            end,	
        },
        {		
            Nazwa = "Zgromadzenie",
            opis = "Skupiasz swoje cząsteczki w jednym miejscu",
            cld = 1,
            dur = 0,
            target = false,
            click = function(ply,dur,cld) 
                if ply.State == 1 then return end
                if CLIENT then
                    ply.p = ply:CreateParticleEffect("duch3",0)
                    ply.a = ply:GetPos()
                    timer.Simple(4,function()
                        if IsValid(ply) then
                            ply.p = ply:CreateParticleEffect("duch",0)
                            ply.State = 1
                            ply.a = nil
                        end
                    end)
                end
                ply.scp343noclip = false 
                ply:SetCollisionGroup( COLLISION_GROUP_NONE ) 
                ply:SetSolid(SOLID_BBOX)
                ply:CollisionRulesChanged()
                ply:SetModelScale(1,0)
                ply:SetNoDraw(false)
                if SERVER then
                    ply.State = 1
                    ply:SetSolid(SOLID_BBOX)
                end
            end,
            reload = function(ply,dur,cld) 
            end,	
        },
        {		
            Nazwa = "Scalenie",
            opis = "Zmieniasz swoją formę w ciało stałe. Uwaga jesteś podatny na ataki.",
            cld = 1,
            dur = 0,
            target = false,
            click = function(ply,dur,cld) 
                if ply.State ~= 1 then return end
                if CLIENT then
                    if IsValid(ply.p) then
                    ply.p:StopEmission(true)
                    end
                    ply:SetColor(Color(255,255,255,255))
                    ply.State = 3
                end
                if SERVER then
                    ply.State = 3
                    local bodygroups = {}
                    for i = 0, ply:GetNumBodyGroups() - 1 do
                        bodygroups[i] = ply:GetBodygroup(i)
                    end
                    local skin = ply:GetSkin()
                    empty = {
                        skin = skin,
                        bodygroups = bodygroups
                    }
                    empty = util.TableToJSON(empty)
                    local str = ply:GetNWString("skingroup","")
                        ply:SetModel(ply:GetNWString("modelduch",ply:GetModel()))
                        str = str ~= "" and str or empty
                        local data = util.JSONToTable(str,empty)
                        if data.skin then
                            ply:SetSkin(data.skin)
                        end
                        if data.bodygroups then
                            for i, bodygroupValue in pairs(data.bodygroups) do
                                ply:SetBodygroup(i, bodygroupValue)
                            end
                        end
                        
                end
            end,
            reload = function(ply,dur,cld) 
            end,	
        },
        {		
            Nazwa = "Zduplikuj",
            opis = "Kradniesz wygląd kogoś innego",
            cld = 1,
            dur = 0,
            target = false,
            click = function(ply,dur,cld) 
                if SERVER then
                    local ent = ply:GetEyeTrace().Entity
                    if !IsValid(ent) or !ent:IsPlayer() then return end
                    ply:SetNWString("modelduch",ent:GetModel())
                    local bodygroups = {}
                    for i = 0, ent:GetNumBodyGroups() - 1 do
                        bodygroups[i] = ent:GetBodygroup(i)
                    end
                    local skin = ent:GetSkin()
                    local data = {
                        skin = skin,
                        bodygroups = bodygroups
                    }

                    -- Kodowanie do JSON
                    local json = util.TableToJSON(data)
                    ply:SetNWString("skingroup",json)
                end
            end,
            reload = function(ply,dur,cld)
                ply:SetNWString("skingroup","")
                ply:SetNWString("modelduch",nil)
            end,	
        }
    
    }
    net.Receive("Syncswep",function(len)
        local ent = net.ReadEntity()
        local index = net.ReadInt(4)
        local targ = net.ReadEntity()
        local cld = net.ReadFloat()
        ent.tbl[index].click(ent:GetOwner(),ent.tbl[index].dur,targ)
        if ent:GetOwner() == LocalPlayer() then
        ent.tblcld[index] = cld ~= -1 and CurTime() + cld or (CurTime() + ent.tbl[index].cld)
        end
    end)
    function SWEP:sync(func,targ,cld)
        net.Start("Syncswep")
            net.WriteEntity(self)
            net.WriteInt(func,4)
            net.WriteEntity(targ)
            net.WriteFloat(cld or -1)
        net.Broadcast()
    end 
    function SWEP:Think()
        local ply = self:GetOwner()
        if CLIENT then
            if self.dframe == nil then self:Deploy() end
            if ply.a ~= nil then
                if IsValid(ply.p) then
                    ply.p:SetControlPoint(1, ply:GetPos() - (ply:GetPos()-ply:EyePos())/2)
                end
            end
        end
        if CLIENT then return end
            if self:GetOwner():KeyReleased(IN_ATTACK) and self.tbl[self.mod].click != nil and (self.tblcld[self.mod] == nil or self.tblcld[self.mod] <= CurTime() ) then
                local targ = nil
                if self.tbl[self.mod].target == true then 
                    local tr = util.TraceLine( {
                        start = ply:EyePos(),
                        endpos = ply:EyePos() + ply:EyeAngles():Forward() * 10000,
                        filter = ply
                    } )
                    if tr.Entity == nil or !tr.Entity:IsPlayer() then return end
                    targ = tr.Entity
                end
                local rep = self.tbl[self.mod].click(self:GetOwner(),self.tbl[self.mod].dur,targ)
                if rep == false then return end
                self.tblcld[self.mod] = CurTime() + self.tbl[self.mod].cld
                self:sync(self.mod,targ)
                
            end
    end
    
    function SWEP:Initialize()
    self:SetHoldType( "normal" )
    self.mod = 1
    self:GetOwner().State = 1
    -- fix bo hook od withergate rozwala
    local tbl = hook.GetTable()
    for k,v in pairs(tbl) do
        if k == "ShouldCollide" then
            for k1,v1 in pairs(v) do
                hook.Remove("ShouldColide","frestscp343")
                if k1 ~= "frestscp3432" and k1 ~= "frestscp343" then
                    hook.Remove("ShouldCollide",k1)
                end
            end
        end
    end
    hook.Add( "ShouldCollide", "frestscp343", function( ent1, ent2 )
        if  (ent1:IsPlayer() or ent2:IsPlayer() ) and (ent2.scp343noclip == true or ent1.scp343noclip == true) then return false end
    end )
    end 
    
    function SWEP:Equip()
        self:Deploy()
    end

    function SWEP:DrawWorldModel()
        local ply = self:GetOwner()
        if ply.a ~= nil then
            if IsValid(ply.p) then
                ply.p:SetControlPoint(1, ply:GetPos() - (ply:GetPos()-ply:EyePos())/2)
            end
        end
    end


game.AddParticles( "particles/chmura.pcf" )
PrecacheParticleSystem("particles/chmura.pcf")

    function SWEP:Deploy()
        if SERVER then
            
            if self:GetOwner().State == nil or self.first == nil then
                self:GetOwner().State = 1
                self.first = 1
            end
        end
        if CLIENT then
            if !IsValid(self:GetOwner().p) and self:GetOwner().State == 1 then
            self:GetOwner().p = self:GetOwner():CreateParticleEffect("duch",0)
            end
        end
            self:GetOwner():SetRenderMode( RENDERMODE_TRANSCOLOR )
            self:GetOwner():SetColor(Color(255,255,255,0))
        
        if CLIENT then
            if self.dframe ~= nil and IsValid(self.dframe) then self.dframe:Remove() end
            self.dframe = vgui.Create("DFrame")
            local dframe = self.dframe
            dframe:SetSize(ScrW()/4, ScrH()*0.125)
            dframe:SetPos(ScrW()/2 - dframe:GetWide()/2,ScrH()*0.95 - dframe:GetTall())
            dframe:ShowCloseButton(false)
            dframe:SetTitle("")


    
            local mpanel = vgui.Create("DFrame")
            
            mpanel:SetSize(ScrH()*0.2,ScrH()*0.2)
            mpanel:SetPos(dframe:GetX() + dframe:GetWide() + ScrW() *0.1,dframe:GetY() - ScrH() *0.1  )
            mpanel:SetModel(LocalPlayer():GetModel())
            mpanel.Paint = nil
            mpanel:ShowCloseButton(false)
            mpanel:SetTitle("")

            local model = vgui.Create("DModelPanel",mpanel)
            model:Dock(FILL)
            model:SetModel(LocalPlayer():GetModel())
            model.last = nil
            local empty = {skin = {}, bodygroups = {}}
            function model:LayoutEntity( ent ) 
                ent:SetAngles(Angle(0,45,0)) 
                local bodygroups = {}
                for i = 0, LocalPlayer():GetNumBodyGroups() - 1 do
                    bodygroups[i] = LocalPlayer():GetBodygroup(i)
                end
                local skin = LocalPlayer():GetSkin()
                empty = {
                    skin = skin,
                    bodygroups = bodygroups
                }
                empty = util.TableToJSON(empty)
                local str = LocalPlayer():GetNWString("skingroup","")
                if self.last ~= str then
                    self.last = str
                    self:SetModel(LocalPlayer():GetNWString("modelduch",LocalPlayer():GetModel()))
                    str = str ~= "" and str or empty
                    local data = util.JSONToTable(str,empty)
                    if data.skin then
                        ent:SetSkin(data.skin)
                    end
                    if data.bodygroups then
                        for i, bodygroupValue in pairs(data.bodygroups) do
                            ent:SetBodygroup(i, bodygroupValue)
                        end
                    end
                end
                return end -- disables default rotation
            function model.Entity:GetPlayerColor() return Vector (0, 0, 0) end
            model.Think = function(self)
                
            end
            function dframe:OnRemove()
                mpanel:Remove()
            end

            local lastid = 0
            local refresh = CurTime() + 5
            local up = vgui.Create("DPanel",dframe)
            up:Dock(FILL)
            up.Paint = function(self2,w,h)
                if lastid ~= self.mod then
                    refresh = CurTime() + 5
                end	
                if refresh > CurTime() and self2:GetAlpha() < 255 then
                    self2:SetAlpha(self2:GetAlpha() + 31)
                elseif refresh <= CurTime() and self2:GetAlpha() > 0 then
                    self2:SetAlpha(self2:GetAlpha() -1 )
                end
            end
            dframe.Paint = function(self,w,h)
                surface.SetDrawColor(Color(83,83,83,Lerp(up:GetAlpha()/255,0,133)))
                surface.DrawRect(0,0,w,h)
            end
            local left = vgui.Create("DPanel",up)
            left:Dock(FILL)
            left:DockPadding(0,0,10,0)
            left.Paint = nil
    
            local right = vgui.Create("DPanel",up)
            right:Dock(RIGHT)
            right:SetSize(ScrW()*0.05)
            
            right.Paint = nil
    
            local name = vgui.Create("DLabel",left)
            name:SetText("Loading...")
            name:Dock(TOP)
            name:DockMargin(0,0,0,10)
            name:Center()
            name.Paint = function(self,w,h)
                surface.SetDrawColor(Color(0,0,0,40))
                surface.DrawRect(0,0,w,h)
            end
    
            local desc = vgui.Create("DLabel",left)
             desc:SetText("Loading...")
             desc:Dock(TOP)
             desc:SetAutoStretchVertical(true)
             desc:SetWrap(true)
             desc.Paint = function(self,w,h)
                surface.SetDrawColor(Color(0,0,0,40))
                surface.DrawRect(0,0,w,h)
            end
    
            local cld = vgui.Create("DLabel",right)
             cld:SetText("Loading...")
             cld:Dock(TOP)
             cld.Paint = nil
    
            local dur = vgui.Create("DLabel",right)
             dur:SetText("Loading...")
             dur:Dock(TOP)
             dur.Paint = nil
    
            local down = vgui.Create("DIconLayout",dframe)
            down:Dock(BOTTOM)
            
            down:SetSize(dframe:GetWide(),ScrH()*0.025)
    
            
            down:SetStretchHeight(false)
            down.Paint = function(self,w,h)
                surface.SetDrawColor(Color(0,0,0,93))
                surface.DrawRect(0,0,w,h)
            end
    
            for k,v in ipairs(self.tbl) do
                local panel = down:Add("DPanel")
                panel:SetText(v.Nazwa)
    
                
                panel:SetSize(math.Clamp((down:GetWide()-(down:GetTall()*0.23))/#self.tbl,down:GetTall(),down:GetWide()))
                if k > 1 then
                panel:Dock(LEFT)
                else
                panel:Dock(RIGHT)
                end
                local label = panel:Add("DButton")
                label:Dock(FILL)
                label:SetTextColor(Color(0,0,0))
                label.Paint = function(self2,w,h)
                    surface.SetDrawColor(Color(128,128,128))
                    if !IsValid(self) then return end
                    if self.tblcld[k] ~= nil and self.tblcld[k] >= CurTime() then
                        surface.SetDrawColor(Color(170,58,54))
                    end
                    if self.mod == k then
                    surface.SetDrawColor(Color(170,168,54))
                    end
    
                    surface.DrawRect(0,0,w,h)
                    surface.SetDrawColor(Color(0,0,0,65))
                    if self.tblcld[k] ~= nil and self.tblcld[k] >= CurTime() then
                        self2:SetText(string.sub(v.Nazwa,0,6) .. " [" .. math.Round(self.tblcld[k]-CurTime()) .. "]" )
                    else
                        self2:SetText(string.sub(v.Nazwa,0,6))
                    end
                    if self.tblcld[k] ~= nil and self.tblcld[k] >= CurTime() then
                        surface.SetDrawColor(Color(218,11,0,115))
                    end
                    for i= 1, 5 do
                        if self.mod == k then
                            local x = -(1 - CurTime()*5 % 3) * 10
                            surface.DrawOutlinedRect(0+x/2, 0+x/2, w-x, h-x,i)
                            local x = (1 - CurTime()*5 % 3) * 20
                            surface.DrawOutlinedRect(0+x/2, 0+x/2, w-x, h-x,i)
                            surface.DrawOutlinedRect(0, 0, w, h,i)
                        else
                            surface.DrawOutlinedRect(0, 0, w, h,i)
                        end
                    end
                end
                function label:DoClick()
                    self.mod = k 
                end
                label:SetText(string.sub(v.Nazwa,0,6))
            end
    
            local function switch(id)
                refresh = CurTime() + 5
                name:SetText(self.tbl[id].Nazwa)
                name:SizeToContents()
                desc:SetText(self.tbl[id].opis)
                if self.tbl[id].cld ~= nil then
                    cld:SetText("Cooldown: ".. self.tbl[id].cld)
                else
                    cld:SetText("")
                end
                if self.tbl[id].cld ~= nil then
                dur:SetText("Długość:".. self.tbl[id].dur)
                else
                dur:SetText("")
                end
            end
    
            
    
            dframe.Think = function()
                
                
                if !LocalPlayer():HasWeapon("frest_duch") then dframe:Remove() end
                if !IsValid(self) then return end
                if lastid ~= self.mod then lastid = self.mod switch(self.mod) end
                if dframe:GetAlpha() == 0 and LocalPlayer():GetActiveWeapon() ~= nil and IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "frest_duch" then
                    dframe:SetAlpha(255)
                elseif dframe:GetAlpha() == 255 and (LocalPlayer():GetActiveWeapon() == nil or !IsValid(LocalPlayer():GetActiveWeapon()) or LocalPlayer():GetActiveWeapon():GetClass() ~= "frest_duch") then
                    dframe:SetAlpha(0)
                end
            end
        end
    end
    
    function SWEP:PrimaryAttack()
        if self:GetOwner():KeyDown(IN_ATTACK) and self.tbl[self.mod].hold != nil then
            self.tbl[self.mod].hold(self:GetOwner())
        end
    end
    
    function SWEP:DrawHUD()
    local ply = LocalPlayer()
        if self.tbl[self.mod].hud != nil then
            self.tbl[self.mod].hud(ply)
        end
    end
    
    function SWEP:Holster( wep )
            return true
    end
    
    function SWEP:SecondaryAttack()
        if SERVER then
            self:SetNextSecondaryFire( CurTime() +0.5 )
            if self.mod + 1 <= #self.tbl then
            self.mod = self.mod + 1
            else
            self.mod = 1 
            end
            net.Start("fresscp343")
                net.WriteTable({ent = self, i = self.mod})
            net.Send(self:GetOwner())
        end
    end
    
    net.Receive("fresscp343",function()
        local tbl = net.ReadTable()
        local ent = tbl.ent
            ent.mod = tbl.i
    end)
    
    function SWEP:Reload()
        if self.tbl[self.mod].reload != nil then
            self.tbl[self.mod].reload(self:GetOwner(),self.tbl[self.mod].dur,self.tbl[self.mod].cld)
        end
    end
    
    function SWEP:OnRemove()	
        if IsValid(self:GetOwner()) then
            local ply = self:GetOwner()
            if IsValid(ply.p) then
             ply.p:StopEmission(true)
            end
            ply.scp343noclip = false 
            ply.State = nil
            ply:SetNoDraw(false)
            ply:SetColor(Color(255,255,255,255))
            ply:SetCollisionGroup( COLLISION_GROUP_NONE ) 
            ply:SetSolid(SOLID_BBOX)
            ply:CollisionRulesChanged()
            ply:SetModelScale(1,0)
        end
    end
    
    hook.Add("EntityTakeDamage","frestDuch",function(ply,dmg)
    if !ply:IsPlayer() or !ply:HasWeapon("frest_duch") then return end
    
    if ply:Health() - dmg:GetDamage() <= 0 then
        local self = ply:GetWeapon("frest_duch")
        self.tbl[1].click(self:GetOwner(),self.tbl[1].dur)
        for i = 1,3 do
        self.tblcld[i] = CurTime() + 60
        end
        self:sync(1,targ,60)
        return true
    end

    end)

    hook.Add("StartCommand","frestDuch",function(ply,cmd)
        if CLIENT then return end
        if !ply:HasWeapon("frest_duch") then return end
        if cmd:KeyDown(IN_ZOOM) and ply.State ~= 2 then
            local self = ply:GetWeapon("frest_duch")
            self.tbl[1].click(self:GetOwner(),self.tbl[1].dur)
            self.tblcld[1] = CurTime() + 1
            self:sync(1,targ)
        end

    end)

    hook.Add( "PlayerFootstep", "frestDuch", function( ply, pos, foot, sound, volume, rf )
        if ply:HasWeapon("frest_duch") and ply.State ~= 3 then
        return true -- Don't allow default footsteps, or other addon footsteps
        end
    end )
    function SWEP:OnDrop()
        self:Remove()
    end

    if SERVER then
        util.AddNetworkString( "fresscp343" )
    end
    if CLIENT then
        net.Receive("fresscp343",function()
            local tbl = net.ReadTable()
            local ent = tbl.ent
                ent.mod = tbl.i
        end)
    end