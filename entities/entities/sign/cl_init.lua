include('shared.lua')

ENT.RenderGroup 		= RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
end

local laser = Material( "models/props_lab/xencrystal_sheet" )
local sprite = Material("sprites/light_glow02_add")

function ENT:DrawTranslucent( flags )

	local ang = self:GetAngles():Forward()*10
	local uang = self:GetAngles():Up()*20
	local pos = self:GetPos()+self:GetAngles():Up()*5
	local rang = self:GetAngles():Right()*10
	local width = 10

	width = 40
	local color = Color(self:GetColor())
	if tonumber(color.r)<10 then color.r=10 end
	if tonumber(color.g)<10 then color.g=10 end
	if tonumber(color.b)<10 then color.b=10 end

	render.SetMaterial(laser)

	render.DrawQuad(pos+uang,pos+rang,pos-ang,pos-rang)
	render.DrawQuad(pos-ang,pos+rang,pos-uang,pos-rang)
	render.DrawQuad(pos+ang,pos+rang,pos+uang,pos-rang)
	render.DrawQuad(pos-uang,pos+rang,pos+ang,pos-rang)

	render.SetMaterial(sprite)

	local eang = self:GetAngles()
	local rot = Vector(-90, 90, 0)

	eang:RotateAroundAxis(eang:Right(), rot.x)
	eang:RotateAroundAxis(eang:Up(), rot.y)
	eang:RotateAroundAxis(eang:Forward(), rot.z)

	cam.Start3D2D(pos, eang, 1)
		local txt = self:GetNWString("text")
		surface.SetDrawColor(0,0,0,255)
		surface.SetFont("Trebuchet18")
		local w,h = surface.GetTextSize(txt)
		w=w+16
		surface.DrawRect(-w*.5, -15-h, w, h)
		draw.DrawText(txt, "Trebuchet18", 0, -15-h, color,1)
	cam.End3D2D()

end

function ENT:Think()

end
