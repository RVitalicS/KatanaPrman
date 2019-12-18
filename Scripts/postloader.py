
import os
from Katana import NodegraphAPI, UI4
from PyUtilModule import RenderManager
from Scripts import scenegraph





def main():

    time = int(NodegraphAPI.GetCurrentTime())
    project_dir = os.path.dirname( NodegraphAPI.NodegraphGlobals.GetProjectFile() )


    Alembic_In_Prman = NodegraphAPI.GetNode("Alembic_In_Prman")
    if Alembic_In_Prman:

        abcAsset = Alembic_In_Prman.getParameter("abcAsset")

        asset_name = os.path.basename(abcAsset.getValue(time))
        asset_name = os.path.splitext(asset_name)[0]


        tree = scenegraph.get_tree()
        if tree:

            Alembic_In_Prman.setName("{}_Import".format(asset_name))

            scenegraph_path = Alembic_In_Prman.getParameter("name").getValue(time)
            abc_children = scenegraph.get_children( scenegraph_path, tree=tree )
            if abc_children:

                scenegraph_path = abc_children[0]
                tree.setLocationCollapsed("/root", scenegraph_path)



                AssetSwitch = NodegraphAPI.GetNode("AssetSwitch")
                if AssetSwitch:

                    target_port = AssetSwitch.addInputPort(asset_name)
                    Alembic_In_Prman.getOutputPort("out").connect(target_port)

                    GraphState = NodegraphAPI.GetNode("rootNode").getParameter("variables.asset.value")
                    GraphState.setValue(asset_name, time)



                LookFileBake = NodegraphAPI.GetNode("LookFileBake")
                if LookFileBake:
                    rootLocations = LookFileBake.getParameter("rootLocations")
                    for bake_path in rootLocations.getChildren():
                        bake_path.setValue(scenegraph_path, time)



                TypesFactory = NodegraphAPI.GetNode("TypesFactory")
                if TypesFactory:
                    NodegraphAPI.SetNodeEdited(TypesFactory, TypesFactory, exclusive=True)


                NodeGraph =  UI4.App.Tabs.FindTopTab('Node Graph')
                if NodeGraph:
                    NodeGraph = NodeGraph.getNodeGraphWidget()

                    point = (-460.162564658229, -69.68818116141864, 0.0)
                    NodeGraph.setEyePoint(point)
                    NodeGraph.update()




                Render = NodegraphAPI.GetNode("Render")
                if Render:
                    NodegraphAPI.SetNodeViewed(Render, Render, exclusive=True)


                    # Viewer = UI4.App.Tabs.FindTopTab("Viewer (Hydra)")
                    # if Viewer:
                    #     Viewer.setCamera(0, "/root/world/cam/camera")


                    RenderManager.StartRender("liveRender", node=Render)
