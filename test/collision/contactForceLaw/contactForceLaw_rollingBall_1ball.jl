module contactForceLaw_rollingBall_1ball

using Modia3D
using Modia3D.StaticArrays
import Modia3D.ModiaMath


vmatGraphics = Modia3D.Material(color="LightBlue" , transparency=0.5)    # material of Graphics
vmatSolids = Modia3D.Material(color="Red" , transparency=0.0)         # material of solids
vmatTable = Modia3D.Material(color="Green", transparency=0.1)         # material of table

cmatTable = Modia3D.ElasticContactMaterial2("BilliardTable")
cmatBall = Modia3D.ElasticContactMaterial2("BilliardBall")

LxGround = 3.0



LyBox = 0.5
LzBox = 0.02
diameter = 0.06
@assembly Table(world) begin
  withBox = Modia3D.Solid(Modia3D.SolidBox(LxGround, LyBox, LzBox) , "DryWood", vmatTable; contactMaterial = cmatTable)
  box1 = Modia3D.Object3D(world, withBox, r=[1.5, 0.0, -LzBox/2], fixed=true, visualizeFrame=false)
end

@assembly OneRollingBall() begin
  world = Modia3D.Object3D(visualizeFrame=false)
  table = Table(world)
  ball1 = Modia3D.Object3D(world, Modia3D.Solid(Modia3D.SolidSphere(diameter), "BilliardBall", vmatSolids ;
                           contactMaterial = cmatBall), fixed = false, r=[0.2, 0.0, diameter/2], v_start=[3.0, 0.0, 0.0], visualizeFrame=true )
end


gravField = Modia3D.UniformGravityField(g=9.81, n=[0,0,-1])
bill = OneRollingBall(sceneOptions=Modia3D.SceneOptions(gravityField=gravField,visualizeFrames=false,
                       defaultFrameLength=0.1,nz_max = 100, enableContactDetection=true, visualizeContactPoints=false, visualizeSupportPoints=false))

#Modia3D.visualizeAssembly!( bill )

model = Modia3D.SimulationModel( bill )
#ModiaMath.print_ModelVariables(model)

using PyPlot
using PyCall

pyplot_rc = PyCall.PyDict(PyPlot.matplotlib."rcParams")
pyplot_rc["font.family"]      = "sans-serif"
pyplot_rc["font.sans-serif"]  = ["Calibri", "Arial", "Verdana", "Lucida Grande"]
pyplot_rc["font.size"]        = 12.0
pyplot_rc["lines.linewidth"]  = 1.5
pyplot_rc["grid.linewidth"]   = 0.5
pyplot_rc["axes.grid"]        = true
pyplot_rc["axes.titlesize"]   = "medium"
pyplot_rc["figure.titlesize"] = "medium"

result = ModiaMath.simulate!(model; stopTime=0.2, tolerance=1e-8, log=true)

fig, ax = PyPlot.subplots(figsize=(3,9))

ModiaMath.plot(result, [("ball1.r[1]"),
                        ("ball1.r[3]"),
                        ("ball1.v[1]"),
                        ("ball1.w[2]")],
                        figure=1, reuse=true)

ModiaMath.plot(result, [ "ball1.r[1]"  "ball1.v[1]"
                         "ball1.r[3]"  "ball1.w[2]"])



ball_r = result.series["ball1.r"][:,1]
t      = result.series["time"]
l_t    = length(t)

dist = ( ball_r[2] - ball_r[1] ) / (t[2] - t[1] )
distEnd = ( ball_r[l_t] - ball_r[l_t - 1] ) / (t[l_t] - t[l_t-1] )

println("dist = ", dist)
println("distEnd = ", distEnd)

println("... success of contactForceLaw_rollingBall_1ball.jl!")
end
