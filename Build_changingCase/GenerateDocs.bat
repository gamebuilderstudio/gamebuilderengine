pushd ..
"c:\Program Files\adobe\Flex Builder 3 Plug-in\sdks\3.2.0\bin\asdoc" ^
   -source-path Projects/Engine/PBEngine/Source -doc-sources "Projects/Engine/PBEngine/Source" ^
   -source-path Projects/Engine/BoxTwoDPhysics/Source -doc-sources "Projects/Engine/BoxTwoDPhysics/Source" ^
   -source-path Projects/Engine/TwoDRenderer/Source -doc-sources "Projects/Engine/TwoDRenderer/Source" ^
   -output "APIDocs" -main-title "PushButton Engine API" -window-title "PushButton Engine API" -external-library-path "Libraries"
popd