----
-- Written by Fesiug
----

CreateClientConVar("ftgid", 1, true, false)
CreateClientConVar("ftgid_show_ents", 1, true, false)
CreateClientConVar("ftgid_realhp", 1, true, false)

CreateClientConVar("ftgid_font_scale", 1, true, false, nil, 0)

local cv = GetConVar("ftgid")
local cv_e = GetConVar("ftgid_show_ents")
local cv_r = GetConVar("ftgid_realhp")
local cv_f = GetConVar("ftgid_font_scale")

function ftgid_regenfonts()
	local cv_ff = cv_f:GetFloat()
	surface.CreateFont( "NTGID_1", {
		font = "Bahnschrift",
		size = ScreenScale(12) * cv_ff,
		weight = 500,
	} )
	surface.CreateFont( "NTGID_2", {
		font = "Bahnschrift",
		size = ScreenScale(6) * cv_ff,
		weight = 0,
	} )
end
ftgid_regenfonts()

cvars.AddChangeCallback("ftgid_font_scale", function()
	ftgid_regenfonts()
end)

local COLOR_WHITE = Color( 255, 255, 255, 255 )
local COLOR_SHAD = Color( 0, 0, 0, 127 )
local DOT = Material("fid/dot.png", "mips smooth")
local hs = 1
local hsv = Vector( hs, hs, hs )
local hsvm = -hsv

local COOLNUM = 0

local lastthing = NULL

hook.Add( "HUDDrawTargetID", "HidePlayerInfo", function()
	if cv:GetBool() then
		local sef = LocalPlayer()
		local tracer = {
			start = sef:EyePos(),
			endpos = sef:EyePos() + ( sef:GetAimVector() * 32768 ),
			filter = {sef, sef:GetVehicle(), IsValid(sef:GetVehicle()) and sef:GetVehicle():GetParent()},
			mins = hsvm,
			maxs = hsv,
			mask = MASK_SHOT,
		}
		local trace = util.TraceHull( tracer )
		local hitent
		if IsValid(trace.Entity) then
			hitent = trace.Entity
			lastthing = hitent
		else
			local trace2 = util.TraceLine( tracer )
			if IsValid(trace2.Entity) then
				hitent = trace2.Entity
				lastthing = hitent
			end
		end
		COOLNUM = math.Approach(COOLNUM, IsValid(hitent) and 1 or 0, FrameTime()/0.05)
		hitent = lastthing
		local ss = ScreenScale(1) * cv_f:GetFloat()
		local tc = GAMEMODE:GetTeamColor( hitent )
		
		if IsValid(hitent) and COOLNUM>0 then
			local text
			if ( hitent:IsPlayer() ) then
				text = hitent:Nick()
			elseif ( cv_e:GetBool() ) then
				text = language.GetPhrase(hitent.PrintName or hitent:GetClass())
			else
				return
			end

			COLOR_WHITE.a = COOLNUM*255
			COLOR_SHAD.a = COOLNUM*200
			
			local tc
			if hitent.Team and hitent:Team() != TEAM_UNASSIGNED then
				tc = hitent:Team()
			end
			
			local entc, sw, sh = hitent:WorldSpaceCenter(), ScrW(), ScrH()
			entc_s = entc:ToScreen()
			local x = math.Round( math.Clamp( entc_s.x, sw * 0.15, sw * 0.85 ) )
			local y = math.Round( math.Clamp( entc_s.y, sh * 0.15, sh * 0.85 ) )

			surface.SetFont( "NTGID_1" )
			local tw = surface.GetTextSize( text )
			tw = math.Clamp( tw, ss*28, ss*64 )
			local tw2 = tw/2

			draw.SimpleText( text, "NTGID_1", x + ss, y, COLOR_SHAD, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
			draw.SimpleText( text, "NTGID_1", x, y - ss, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

			local cv_re = cv_r:GetBool()
			local e_armor = hitent.Armor and isfunction(hitent.Armor) and hitent:Armor() > 0 
			if e_armor then
				local text = cv_re and "♦ " .. hitent:Armor() or math.Round(hitent:Armor() / hitent:GetMaxArmor() * 100, 2) .. "%"
				draw.SimpleText( text, "NTGID_2", x + tw2 + ss,	y + ss*12, COLOR_SHAD, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
				draw.SimpleText( text, "NTGID_2", x + tw2,		y - ss + ss*12, COLOR_WHITE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
			end
			if hitent:Health() > 0 then
				local text = cv_re and hitent:Health() .. " ♥" or math.Round(hitent:Health() / hitent:GetMaxHealth() * 100, 2) .. "%"
				draw.SimpleText( text, "NTGID_2", x - (e_armor and tw2 or 0) + ss,	y + ss*12, COLOR_SHAD, (e_armor and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER), TEXT_ALIGN_TOP )
				draw.SimpleText( text, "NTGID_2", x - (e_armor and tw2 or 0),		y - ss + ss*12, COLOR_WHITE, (e_armor and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER), TEXT_ALIGN_TOP )
			end
			if tc then
				local teamcol = team.GetColor(tc)
				local teamname = team.GetName(tc)
				teamcol.a = teamcol.a * COOLNUM
				draw.SimpleText( teamname, "NTGID_2", x + ss, y + ss - ss*6, COLOR_SHAD, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
				draw.SimpleText( teamname, "NTGID_2", x, y - ss*6, teamcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
			end

			return true
		end
	end
end )