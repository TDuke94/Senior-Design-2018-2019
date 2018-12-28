; ModuleID = 'C:/Users/TimothyDuke/workspace/ArtyFreeTest/src/dispatch.c'
source_filename = "C:/Users/TimothyDuke/workspace/ArtyFreeTest/src/dispatch.c"
target datalayout = "e-m:e-p:32:32-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "armv7-none--eabi"

@.str = private unnamed_addr constant [17 x i8] c"I'm in dispatch\0A\00", align 1
@.str.1 = private unnamed_addr constant [5 x i8] c"Blab\00", align 1
@.str.2 = private unnamed_addr constant [7 x i8] c"ChatTX\00", align 1
@.str.3 = private unnamed_addr constant [6 x i8] c"Blink\00", align 1
@.str.4 = private unnamed_addr constant [23 x i8] c"error in creating task\00", align 1

; Function Attrs: nounwind
define void @dispatchPipeline() #0 !dbg !15 !xidane.fname !19 !xidane.function_declaration_type !20 !xidane.function_declaration_filename !21 !xidane.ExternC !22 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i8*, align 4
  %4 = alloca i8*, align 4
  %5 = alloca i8*, align 4
  call void @llvm.dbg.declare(metadata i32* %1, metadata !23, metadata !25), !dbg !26
  store i32 400, i32* %1, align 4, !dbg !26
  call void @llvm.dbg.declare(metadata i32* %2, metadata !27, metadata !25), !dbg !28
  call void @llvm.dbg.declare(metadata i8** %3, metadata !29, metadata !25), !dbg !32
  store i8* null, i8** %3, align 4, !dbg !32
  call void @llvm.dbg.declare(metadata i8** %4, metadata !33, metadata !25), !dbg !34
  store i8* null, i8** %4, align 4, !dbg !34
  call void @llvm.dbg.declare(metadata i8** %5, metadata !35, metadata !25), !dbg !36
  store i8* null, i8** %5, align 4, !dbg !36
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str, i32 0, i32 0)), !dbg !37
  %6 = load i32, i32* %1, align 4, !dbg !38
  %7 = trunc i32 %6 to i16, !dbg !38
  %8 = call i32 @xTaskCreate(void (i8*)* @blabber, i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.1, i32 0, i32 0), i16 zeroext %7, i8* null, i32 1, i8** %3), !dbg !39
  store i32 %8, i32* %2, align 4, !dbg !40
  %9 = load i32, i32* %2, align 4, !dbg !41
  %10 = icmp ne i32 %9, 1, !dbg !43
  br i1 %10, label %11, label %12, !dbg !44

; <label>:11:                                     ; preds = %0
  call void @printError(), !dbg !45
  br label %12, !dbg !45

; <label>:12:                                     ; preds = %11, %0
  %13 = load i32, i32* %1, align 4, !dbg !47
  %14 = trunc i32 %13 to i16, !dbg !47
  %15 = call i32 @xTaskCreate(void (i8*)* @chatTX, i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.2, i32 0, i32 0), i16 zeroext %14, i8* null, i32 1, i8** %4), !dbg !48
  store i32 %15, i32* %2, align 4, !dbg !49
  %16 = load i32, i32* %2, align 4, !dbg !50
  %17 = icmp ne i32 %16, 1, !dbg !52
  br i1 %17, label %18, label %19, !dbg !53

; <label>:18:                                     ; preds = %12
  call void @printError(), !dbg !54
  br label %19, !dbg !54

; <label>:19:                                     ; preds = %18, %12
  %20 = load i32, i32* %1, align 4, !dbg !56
  %21 = trunc i32 %20 to i16, !dbg !56
  %22 = call i32 @xTaskCreate(void (i8*)* @blinky, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.3, i32 0, i32 0), i16 zeroext %21, i8* null, i32 1, i8** %5), !dbg !57
  store i32 %22, i32* %2, align 4, !dbg !58
  %23 = load i32, i32* %2, align 4, !dbg !59
  %24 = icmp ne i32 %23, 1, !dbg !61
  br i1 %24, label %25, label %26, !dbg !62

; <label>:25:                                     ; preds = %19
  call void @printError(), !dbg !63
  br label %26, !dbg !63

; <label>:26:                                     ; preds = %25, %19
  call void @vTaskStartScheduler(), !dbg !65
  ret void, !dbg !66
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

declare !xidane.fname !67 !xidane.function_declaration_type !68 !xidane.function_declaration_filename !69 !xidane.ExternC !22 void @xil_printf(i8*, ...) #2

declare !xidane.fname !70 !xidane.function_declaration_type !71 !xidane.function_declaration_filename !72 !xidane.ExternC !22 i32 @xTaskCreate(void (i8*)*, i8*, i16 zeroext, i8*, i32, i8**) #2

declare !xidane.fname !73 !xidane.function_declaration_type !74 !xidane.function_declaration_filename !75 !xidane.ExternC !22 void @blabber(i8*) #2

; Function Attrs: nounwind
define void @printError() #0 !dbg !76 !xidane.fname !77 !xidane.function_declaration_type !20 !xidane.function_declaration_filename !78 !xidane.ExternC !22 {
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([23 x i8], [23 x i8]* @.str.4, i32 0, i32 0)), !dbg !79
  ret void, !dbg !80
}

declare !xidane.fname !81 !xidane.function_declaration_type !74 !xidane.function_declaration_filename !75 !xidane.ExternC !22 void @chatTX(i8*) #2

declare !xidane.fname !82 !xidane.function_declaration_type !74 !xidane.function_declaration_filename !75 !xidane.ExternC !22 void @blinky(i8*) #2

declare !xidane.fname !83 !xidane.function_declaration_type !20 !xidane.function_declaration_filename !72 !xidane.ExternC !22 void @vTaskStartScheduler() #2

; Function Attrs: nounwind
define void @continualDispatcher() #0 !dbg !84 !xidane.fname !85 !xidane.function_declaration_type !20 !xidane.function_declaration_filename !21 !xidane.ExternC !22 {
  ret void, !dbg !86
}

attributes #0 = { nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-a9" "target-features"="+dsp,+strict-align,+vfp3,-crypto,-d16,-fp-armv8,-fp-only-sp,-fp16,-neon,-vfp4" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-a9" "target-features"="+dsp,+strict-align,+vfp3,-crypto,-d16,-fp-armv8,-fp-only-sp,-fp16,-neon,-vfp4" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!10, !11, !12, !13}
!llvm.ident = !{!14}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 3.9.0 (tags/RELEASE_390/final)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !3)
!1 = !DIFile(filename: "../src\5Cdispatch.c", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!2 = !{}
!3 = !{!4, !5, !8}
!4 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 32, align: 32)
!5 = !DIDerivedType(tag: DW_TAG_typedef, name: "UBaseType_t", file: !6, line: 60, baseType: !7)
!6 = !DIFile(filename: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/portmacro.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!7 = !DIBasicType(name: "long unsigned int", size: 32, align: 32, encoding: DW_ATE_unsigned)
!8 = !DIDerivedType(tag: DW_TAG_typedef, name: "BaseType_t", file: !6, line: 59, baseType: !9)
!9 = !DIBasicType(name: "long int", size: 32, align: 32, encoding: DW_ATE_signed)
!10 = !{i32 2, !"Dwarf Version", i32 4}
!11 = !{i32 2, !"Debug Info Version", i32 3}
!12 = !{i32 1, !"wchar_size", i32 4}
!13 = !{i32 1, !"min_enum_size", i32 4}
!14 = !{!"clang version 3.9.0 (tags/RELEASE_390/final)"}
!15 = distinct !DISubprogram(name: "dispatchPipeline", scope: !16, file: !16, line: 35, type: !17, isLocal: false, isDefinition: true, scopeLine: 36, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!16 = !DIFile(filename: "C:/Users/TimothyDuke/workspace/ArtyFreeTest/src/dispatch.c", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!17 = !DISubroutineType(types: !18)
!18 = !{null}
!19 = !{!"dispatchPipeline"}
!20 = !{!"void."}
!21 = !{!"../src/dispatch.h"}
!22 = !{!"t"}
!23 = !DILocalVariable(name: "STACK_SIZE", scope: !15, file: !16, line: 37, type: !24)
!24 = !DIBasicType(name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!25 = !DIExpression()
!26 = !DILocation(line: 37, column: 6, scope: !15)
!27 = !DILocalVariable(name: "xReturned", scope: !15, file: !16, line: 39, type: !8)
!28 = !DILocation(line: 39, column: 13, scope: !15)
!29 = !DILocalVariable(name: "xBlabHandle", scope: !15, file: !16, line: 40, type: !30)
!30 = !DIDerivedType(tag: DW_TAG_typedef, name: "TaskHandle_t", file: !31, line: 62, baseType: !4)
!31 = !DIFile(filename: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp\5Ctask.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!32 = !DILocation(line: 40, column: 15, scope: !15)
!33 = !DILocalVariable(name: "xChatTXHandle", scope: !15, file: !16, line: 41, type: !30)
!34 = !DILocation(line: 41, column: 15, scope: !15)
!35 = !DILocalVariable(name: "xBlinkHandle", scope: !15, file: !16, line: 42, type: !30)
!36 = !DILocation(line: 42, column: 15, scope: !15)
!37 = !DILocation(line: 44, column: 2, scope: !15)
!38 = !DILocation(line: 49, column: 4, scope: !15)
!39 = !DILocation(line: 46, column: 14, scope: !15)
!40 = !DILocation(line: 46, column: 12, scope: !15)
!41 = !DILocation(line: 55, column: 6, scope: !42)
!42 = distinct !DILexicalBlock(scope: !15, file: !16, line: 55, column: 6)
!43 = !DILocation(line: 55, column: 16, scope: !42)
!44 = !DILocation(line: 55, column: 6, scope: !15)
!45 = !DILocation(line: 55, column: 27, scope: !46)
!46 = !DILexicalBlockFile(scope: !42, file: !16, discriminator: 1)
!47 = !DILocation(line: 60, column: 4, scope: !15)
!48 = !DILocation(line: 57, column: 14, scope: !15)
!49 = !DILocation(line: 57, column: 12, scope: !15)
!50 = !DILocation(line: 66, column: 6, scope: !51)
!51 = distinct !DILexicalBlock(scope: !15, file: !16, line: 66, column: 6)
!52 = !DILocation(line: 66, column: 16, scope: !51)
!53 = !DILocation(line: 66, column: 6, scope: !15)
!54 = !DILocation(line: 66, column: 27, scope: !55)
!55 = !DILexicalBlockFile(scope: !51, file: !16, discriminator: 1)
!56 = !DILocation(line: 71, column: 5, scope: !15)
!57 = !DILocation(line: 68, column: 14, scope: !15)
!58 = !DILocation(line: 68, column: 12, scope: !15)
!59 = !DILocation(line: 77, column: 7, scope: !60)
!60 = distinct !DILexicalBlock(scope: !15, file: !16, line: 77, column: 7)
!61 = !DILocation(line: 77, column: 17, scope: !60)
!62 = !DILocation(line: 77, column: 7, scope: !15)
!63 = !DILocation(line: 77, column: 28, scope: !64)
!64 = !DILexicalBlockFile(scope: !60, file: !16, discriminator: 1)
!65 = !DILocation(line: 80, column: 2, scope: !15)
!66 = !DILocation(line: 83, column: 2, scope: !15)
!67 = !{!"xil_printf"}
!68 = !{!"void.const char8 *.1"}
!69 = !{!"C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/xil_printf.h"}
!70 = !{!"xTaskCreate"}
!71 = !{!"BaseType_t.TaskFunction_t.1.const char *const.1.const uint16_t.0.void *const.1.UBaseType_t.0.TaskHandle_t *const.1"}
!72 = !{!"C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp\5Ctask.h"}
!73 = !{!"blabber"}
!74 = !{!"void.void *.1"}
!75 = !{!"../src/talky.h"}
!76 = distinct !DISubprogram(name: "printError", scope: !16, file: !16, line: 98, type: !17, isLocal: false, isDefinition: true, scopeLine: 99, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!77 = !{!"printError"}
!78 = !{!"C:/Users/TimothyDuke/workspace/ArtyFreeTest/src/dispatch.c"}
!79 = !DILocation(line: 100, column: 2, scope: !76)
!80 = !DILocation(line: 101, column: 1, scope: !76)
!81 = !{!"chatTX"}
!82 = !{!"blinky"}
!83 = !{!"vTaskStartScheduler"}
!84 = distinct !DISubprogram(name: "continualDispatcher", scope: !16, file: !16, line: 92, type: !17, isLocal: false, isDefinition: true, scopeLine: 93, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!85 = !{!"continualDispatcher"}
!86 = !DILocation(line: 95, column: 2, scope: !84)
