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
		blursize = 0,
	} )
	surface.CreateFont( "NTGID_1_s", {
		font = "Bahnschrift",
		size = ScreenScale(12) * cv_ff,
		weight = 500,
		blursize = 100,
	} )
	surface.CreateFont( "NTGID_2", {
		font = "Bahnschrift",
		size = ScreenScale(6) * cv_ff,
		weight = 0,
		blursize = 0,
	} )
	surface.CreateFont( "NTGID_2_s", {
		font = "Bahnschrift",
		size = ScreenScale(6) * cv_ff,
		weight = 0,
		blursize = 100,
	} )
end
ftgid_regenfonts()

cvars.AddChangeCallback("ftgid_font_scale", function()
	ftgid_regenfonts()
end)

local def = Color( 255, 255, 100, 255 )
local COLOR_WHITE = Color( 255, 255, 255, 255 )
local COLOR_SHAD = Color( 0, 0, 0, 127 )
local DOT = Material("fid/dot.png", "mips smooth")
local HULLSIZE = 4

local COOLNUM = 0

hook.Add( "HUDDrawTargetID", "HidePlayerInfo", function()
	if cv:GetBool() then

	local sef = LocalPlayer()
	local trace = util.TraceLine( {
		start = sef:EyePos(),
		endpos = sef:EyePos() + ( sef:GetAimVector() * 32768 ),
		filter = {sef, sef:GetVehicle(), IsValid(sef:GetVehicle()) and sef:GetVehicle():GetParent()},
		mask = MASK_SHOT_HULL
	} )
	if ( !trace.Hit ) then COOLNUM = 0 return end
	if ( !trace.HitNonWorld ) then COOLNUM = 0 return end
	local hitent = trace.Entity
	local ss = ScreenScale(1) * cv_f:GetFloat()
	local tc = GAMEMODE:GetTeamColor( hitent )
	
	local text = "ERROR"
	local font = "NTGID_1"
	local font_s = "NTGID_1_s"
	
	if hitent and hitent:IsValid() then
		if ( hitent:IsPlayer() ) then
			text = hitent:Nick()
		elseif sef:GetVehicle() == hitent then
			COOLNUM = 0
			return
		-- elseif ( cv_e:GetBool() and hitent:IsScripted() ) then
		-- 	text = hitent.PrintName or "(SENT missing PrintName)"
		elseif ( cv_e:GetBool() ) then
			text = language.GetPhrase(hitent.PrintName or hitent:GetClass())
		else
			COOLNUM = 0
			return
			--text = hitent:GetClass()
		end
	end

	COLOR_WHITE.a = COOLNUM*255
	COLOR_SHAD.a = COOLNUM*127
	COOLNUM = math.Approach(COOLNUM, 1, FrameTime()/0.2)
	
	local tc
	if hitent.Team and hitent:Team() != TEAM_UNASSIGNED then
		tc = hitent:Team()
	end
	
	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )

	local mememm, scrw, scrh = hitent:WorldSpaceCenter(), ScrW(), ScrH()
	mememmm = mememm:ToScreen()
	local x = math.Clamp(mememmm.x, 0+w*0.5, scrw-w*0.5)
	local y = math.Clamp(mememmm.y+h*0.5, 0, scrh-h*1.5)
	
	x = x - w / 2
	--y = y + (ss*30)
	
	-- The fonts internal drop shadow looks lousy with AA on
	surface.SetFont( font_s )
	draw.SimpleText( text, font, x + ss, y + ss, COLOR_SHAD )
	surface.SetFont( font )
	draw.SimpleText( text, font, x, y, COLOR_WHITE )

	if tc then
		local teamcol = team.GetColor(tc)
		surface.SetMaterial( DOT )
		surface.SetDrawColor( COLOR_SHAD )
		surface.DrawTexturedRect( x - (ss*(5-1)), y + (ss*(5+1)), (ss*4), (ss*4) )
		surface.SetDrawColor( teamcol )
		surface.DrawTexturedRect( x - (ss*5), y + (ss*5), (ss*4), (ss*4) )
	end
	
	--y = y + h + 5
	
	font_s = "NTGID_2"
	font = "NTGID_2"

	if tc then
		local teamtext = team.GetName( tc )
		surface.SetFont( font )
		local tw, th = surface.GetTextSize( text )
		draw.SimpleText( teamtext, font, x, y, teamcol )
	end
	
	COLOR_WHITE.r = color_white.r
	COLOR_WHITE.g = color_white.g
	COLOR_WHITE.b = color_white.b
	
	local cv_re = cv_r:GetBool()
	if hitent:Health() > 0 then
		local text = cv_re and hitent:Health() .. " ♥" or math.Round(hitent:Health() / hitent:GetMaxHealth() * 100, 2) .. "%"
		
		surface.SetFont( font )
		local w2, h2 = surface.GetTextSize( text )
		
		surface.SetFont( font_s )
		draw.SimpleText( text, font, x + ss, y + (ss*12), COLOR_SHAD )
		surface.SetFont( font )
		draw.SimpleText( text, font, x, y + (ss*11), COLOR_WHITE )
	end

	if hitent.Armor and isfunction(hitent.Armor) and hitent:Armor() > 0 then
		local text = cv_re and "♦ " .. hitent:Armor() or math.Round(hitent:Armor() / hitent:GetMaxArmor() * 100, 2) .. "%"
		
		surface.SetFont( font )
		local w2, h2 = surface.GetTextSize( text )
		
		surface.SetFont( font_s )
		draw.SimpleText( text, font, x + ss + w, y + (ss*12), COLOR_SHAD, 2)
		surface.SetFont( font )
		draw.SimpleText( text, font, x + w, y + (ss*11), COLOR_WHITE, 2 )
	end

	return true

	end
end )