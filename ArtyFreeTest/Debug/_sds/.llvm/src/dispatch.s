; ModuleID = 'C:/Users/TimothyDuke/workspace/ArtyFreeTest/src/dispatch.c'
source_filename = "C:/Users/TimothyDuke/workspace/ArtyFreeTest/src/dispatch.c"
target datalayout = "e-m:e-p:32:32-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "armv7-none--eabi"

%struct.QueueData = type { i8*, i8*, i32, i32 }

@.str = private unnamed_addr constant [17 x i8] c"I'm in dispatch\0A\00", align 1
@.str.1 = private unnamed_addr constant [5 x i8] c"Blab\00", align 1
@.str.2 = private unnamed_addr constant [7 x i8] c"ChatTX\00", align 1
@.str.3 = private unnamed_addr constant [6 x i8] c"Blink\00", align 1
@.str.4 = private unnamed_addr constant [6 x i8] c"QSend\00", align 1
@.str.5 = private unnamed_addr constant [9 x i8] c"QReceive\00", align 1
@.str.6 = private unnamed_addr constant [23 x i8] c"error in creating task\00", align 1

; Function Attrs: nounwind
define void @dispatchPipeline() #0 !dbg !20 !xidane.fname !24 !xidane.function_declaration_type !25 !xidane.function_declaration_filename !26 !xidane.ExternC !27 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca i8*, align 4
  %5 = alloca %struct.QueueData*, align 4
  %6 = alloca i32, align 4
  %7 = alloca i8*, align 4
  %8 = alloca i8*, align 4
  %9 = alloca i8*, align 4
  %10 = alloca i8*, align 4
  %11 = alloca i8*, align 4
  call void @llvm.dbg.declare(metadata i32* %1, metadata !28, metadata !30), !dbg !31
  store i32 400, i32* %1, align 4, !dbg !31
  call void @llvm.dbg.declare(metadata i32* %2, metadata !32, metadata !30), !dbg !33
  store i32 5, i32* %2, align 4, !dbg !33
  call void @llvm.dbg.declare(metadata i32* %3, metadata !34, metadata !30), !dbg !35
  store i32 30, i32* %3, align 4, !dbg !35
  call void @llvm.dbg.declare(metadata i8** %4, metadata !36, metadata !30), !dbg !39
  store i8* null, i8** %4, align 4, !dbg !39
  call void @llvm.dbg.declare(metadata %struct.QueueData** %5, metadata !40, metadata !30), !dbg !50
  call void @llvm.dbg.declare(metadata i32* %6, metadata !51, metadata !30), !dbg !52
  call void @llvm.dbg.declare(metadata i8** %7, metadata !53, metadata !30), !dbg !56
  store i8* null, i8** %7, align 4, !dbg !56
  call void @llvm.dbg.declare(metadata i8** %8, metadata !57, metadata !30), !dbg !58
  store i8* null, i8** %8, align 4, !dbg !58
  call void @llvm.dbg.declare(metadata i8** %9, metadata !59, metadata !30), !dbg !60
  store i8* null, i8** %9, align 4, !dbg !60
  call void @llvm.dbg.declare(metadata i8** %10, metadata !61, metadata !30), !dbg !62
  store i8* null, i8** %10, align 4, !dbg !62
  call void @llvm.dbg.declare(metadata i8** %11, metadata !63, metadata !30), !dbg !64
  store i8* null, i8** %11, align 4, !dbg !64
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str, i32 0, i32 0)), !dbg !65
  %12 = load i32, i32* %1, align 4, !dbg !66
  %13 = trunc i32 %12 to i16, !dbg !66
  %14 = call i32 @xTaskCreate(void (i8*)* @blabber, i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.1, i32 0, i32 0), i16 zeroext %13, i8* null, i32 1, i8** %7), !dbg !67
  store i32 %14, i32* %6, align 4, !dbg !68
  %15 = load i32, i32* %6, align 4, !dbg !69
  %16 = icmp ne i32 %15, 1, !dbg !71
  br i1 %16, label %17, label %18, !dbg !72

; <label>:17:                                     ; preds = %0
  call void @printError(), !dbg !73
  br label %18, !dbg !73

; <label>:18:                                     ; preds = %17, %0
  %19 = load i32, i32* %1, align 4, !dbg !75
  %20 = trunc i32 %19 to i16, !dbg !75
  %21 = call i32 @xTaskCreate(void (i8*)* @chatTX, i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.2, i32 0, i32 0), i16 zeroext %20, i8* null, i32 1, i8** %8), !dbg !76
  store i32 %21, i32* %6, align 4, !dbg !77
  %22 = load i32, i32* %6, align 4, !dbg !78
  %23 = icmp ne i32 %22, 1, !dbg !80
  br i1 %23, label %24, label %25, !dbg !81

; <label>:24:                                     ; preds = %18
  call void @printError(), !dbg !82
  br label %25, !dbg !82

; <label>:25:                                     ; preds = %24, %18
  %26 = load i32, i32* %1, align 4, !dbg !84
  %27 = trunc i32 %26 to i16, !dbg !84
  %28 = call i32 @xTaskCreate(void (i8*)* @blinky, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.3, i32 0, i32 0), i16 zeroext %27, i8* null, i32 1, i8** %9), !dbg !85
  store i32 %28, i32* %6, align 4, !dbg !86
  %29 = load i32, i32* %6, align 4, !dbg !87
  %30 = icmp ne i32 %29, 1, !dbg !89
  br i1 %30, label %31, label %32, !dbg !90

; <label>:31:                                     ; preds = %25
  call void @printError(), !dbg !91
  br label %32, !dbg !91

; <label>:32:                                     ; preds = %31, %25
  %33 = load i32, i32* %1, align 4, !dbg !93
  %34 = trunc i32 %33 to i16, !dbg !93
  %35 = call i32 @xTaskCreate(void (i8*)* @SendTask, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.4, i32 0, i32 0), i16 zeroext %34, i8* null, i32 1, i8** %10), !dbg !94
  store i32 %35, i32* %6, align 4, !dbg !95
  %36 = load i32, i32* %6, align 4, !dbg !96
  %37 = icmp ne i32 %36, 1, !dbg !98
  br i1 %37, label %38, label %39, !dbg !99

; <label>:38:                                     ; preds = %32
  call void @printError(), !dbg !100
  br label %39, !dbg !100

; <label>:39:                                     ; preds = %38, %32
  %40 = call i8* @pvPortMalloc(i32 16), !dbg !102
  %41 = bitcast i8* %40 to %struct.QueueData*, !dbg !102
  store %struct.QueueData* %41, %struct.QueueData** %5, align 4, !dbg !103
  %42 = load i32, i32* %2, align 4, !dbg !104
  %43 = load i32, i32* %3, align 4, !dbg !104
  %44 = call i8* @xQueueGenericCreate(i32 %42, i32 %43, i8 zeroext 0), !dbg !104
  %45 = load %struct.QueueData*, %struct.QueueData** %5, align 4, !dbg !105
  %46 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %45, i32 0, i32 0, !dbg !106
  store i8* %44, i8** %46, align 4, !dbg !107
  %47 = load i32, i32* %2, align 4, !dbg !108
  %48 = load %struct.QueueData*, %struct.QueueData** %5, align 4, !dbg !109
  %49 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %48, i32 0, i32 2, !dbg !110
  store i32 %47, i32* %49, align 4, !dbg !111
  %50 = load i32, i32* %3, align 4, !dbg !112
  %51 = load %struct.QueueData*, %struct.QueueData** %5, align 4, !dbg !113
  %52 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %51, i32 0, i32 3, !dbg !114
  store i32 %50, i32* %52, align 4, !dbg !115
  %53 = load i32, i32* %1, align 4, !dbg !116
  %54 = trunc i32 %53 to i16, !dbg !116
  %55 = load %struct.QueueData*, %struct.QueueData** %5, align 4, !dbg !117
  %56 = bitcast %struct.QueueData* %55 to i8*, !dbg !118
  %57 = call i32 @xTaskCreate(void (i8*)* @ReceiveTask, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.5, i32 0, i32 0), i16 zeroext %54, i8* %56, i32 1, i8** %11), !dbg !119
  store i32 %57, i32* %6, align 4, !dbg !120
  %58 = load i32, i32* %6, align 4, !dbg !121
  %59 = icmp ne i32 %58, 1, !dbg !123
  br i1 %59, label %60, label %61, !dbg !124

; <label>:60:                                     ; preds = %39
  call void @printError(), !dbg !125
  br label %61, !dbg !125

; <label>:61:                                     ; preds = %60, %39
  %62 = load i32, i32* %1, align 4, !dbg !127
  %63 = trunc i32 %62 to i16, !dbg !127
  %64 = load %struct.QueueData*, %struct.QueueData** %5, align 4, !dbg !128
  %65 = bitcast %struct.QueueData* %64 to i8*, !dbg !129
  %66 = call i32 @xTaskCreate(void (i8*)* @SendTask, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.4, i32 0, i32 0), i16 zeroext %63, i8* %65, i32 1, i8** %10), !dbg !130
  store i32 %66, i32* %6, align 4, !dbg !131
  %67 = load i32, i32* %6, align 4, !dbg !132
  %68 = icmp ne i32 %67, 1, !dbg !134
  br i1 %68, label %69, label %70, !dbg !135

; <label>:69:                                     ; preds = %61
  call void @printError(), !dbg !136
  br label %70, !dbg !136

; <label>:70:                                     ; preds = %69, %61
  call void @vTaskStartScheduler(), !dbg !138
  ret void, !dbg !139
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

declare !xidane.fname !140 !xidane.function_declaration_type !141 !xidane.function_declaration_filename !142 !xidane.ExternC !27 void @xil_printf(i8*, ...) #2

declare !xidane.fname !143 !xidane.function_declaration_type !144 !xidane.function_declaration_filename !145 !xidane.ExternC !27 i32 @xTaskCreate(void (i8*)*, i8*, i16 zeroext, i8*, i32, i8**) #2

declare !xidane.fname !146 !xidane.function_declaration_type !147 !xidane.function_declaration_filename !148 !xidane.ExternC !27 void @blabber(i8*) #2

; Function Attrs: nounwind
define void @printError() #0 !dbg !149 !xidane.fname !150 !xidane.function_declaration_type !25 !xidane.function_declaration_filename !151 !xidane.ExternC !27 {
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([23 x i8], [23 x i8]* @.str.6, i32 0, i32 0)), !dbg !152
  ret void, !dbg !153
}

declare !xidane.fname !154 !xidane.function_declaration_type !147 !xidane.function_declaration_filename !148 !xidane.ExternC !27 void @chatTX(i8*) #2

declare !xidane.fname !155 !xidane.function_declaration_type !147 !xidane.function_declaration_filename !148 !xidane.ExternC !27 void @blinky(i8*) #2

declare !xidane.fname !156 !xidane.function_declaration_type !147 !xidane.function_declaration_filename !157 !xidane.ExternC !27 void @SendTask(i8*) #2

declare !xidane.fname !158 !xidane.function_declaration_type !159 !xidane.function_declaration_filename !160 !xidane.ExternC !27 i8* @pvPortMalloc(i32) #2

declare !xidane.fname !161 !xidane.function_declaration_type !162 !xidane.function_declaration_filename !163 !xidane.ExternC !27 i8* @xQueueGenericCreate(i32, i32, i8 zeroext) #2

declare !xidane.fname !164 !xidane.function_declaration_type !147 !xidane.function_declaration_filename !157 !xidane.ExternC !27 void @ReceiveTask(i8*) #2

declare !xidane.fname !165 !xidane.function_declaration_type !25 !xidane.function_declaration_filename !145 !xidane.ExternC !27 void @vTaskStartScheduler() #2

; Function Attrs: nounwind
define void @continualDispatcher(i8*) #0 !dbg !166 !xidane.fname !169 !xidane.function_declaration_type !147 !xidane.function_declaration_filename !26 !xidane.ExternC !27 {
  %2 = alloca i8*, align 4
  store i8* %0, i8** %2, align 4
  call void @llvm.dbg.declare(metadata i8** %2, metadata !170, metadata !30), !dbg !171
  ret void, !dbg !172
}

attributes #0 = { nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-a9" "target-features"="+dsp,+strict-align,+vfp3,-crypto,-d16,-fp-armv8,-fp-only-sp,-fp16,-neon,-vfp4" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-a9" "target-features"="+dsp,+strict-align,+vfp3,-crypto,-d16,-fp-armv8,-fp-only-sp,-fp16,-neon,-vfp4" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!15, !16, !17, !18}
!llvm.ident = !{!19}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 3.9.0 (tags/RELEASE_390/final)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !3)
!1 = !DIFile(filename: "../src\5Cdispatch.c", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!2 = !{}
!3 = !{!4, !5, !8, !10}
!4 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 32, align: 32)
!5 = !DIDerivedType(tag: DW_TAG_typedef, name: "UBaseType_t", file: !6, line: 60, baseType: !7)
!6 = !DIFile(filename: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/portmacro.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!7 = !DIBasicType(name: "long unsigned int", size: 32, align: 32, encoding: DW_ATE_unsigned)
!8 = !DIDerivedType(tag: DW_TAG_typedef, name: "BaseType_t", file: !6, line: 59, baseType: !9)
!9 = !DIBasicType(name: "long int", size: 32, align: 32, encoding: DW_ATE_signed)
!10 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !11, line: 20, baseType: !12)
!11 = !DIFile(filename: "E:/SDSoC/SDK/2018.2/gnu/aarch32/nt/gcc-arm-none-eabi/arm-none-eabi/libc/usr/include\5Csys/_stdint.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!12 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint8_t", file: !13, line: 29, baseType: !14)
!13 = !DIFile(filename: "E:/SDSoC/SDK/2018.2/gnu/aarch32/nt/gcc-arm-none-eabi/arm-none-eabi/libc/usr/include\5Cmachine/_default_types.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!14 = !DIBasicType(name: "unsigned char", size: 8, align: 8, encoding: DW_ATE_unsigned_char)
!15 = !{i32 2, !"Dwarf Version", i32 4}
!16 = !{i32 2, !"Debug Info Version", i32 3}
!17 = !{i32 1, !"wchar_size", i32 4}
!18 = !{i32 1, !"min_enum_size", i32 4}
!19 = !{!"clang version 3.9.0 (tags/RELEASE_390/final)"}
!20 = distinct !DISubprogram(name: "dispatchPipeline", scope: !21, file: !21, line: 35, type: !22, isLocal: false, isDefinition: true, scopeLine: 36, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!21 = !DIFile(filename: "C:/Users/TimothyDuke/workspace/ArtyFreeTest/src/dispatch.c", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!22 = !DISubroutineType(types: !23)
!23 = !{null}
!24 = !{!"dispatchPipeline"}
!25 = !{!"void."}
!26 = !{!"../src/dispatch.h"}
!27 = !{!"t"}
!28 = !DILocalVariable(name: "STACK_SIZE", scope: !20, file: !21, line: 37, type: !29)
!29 = !DIBasicType(name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!30 = !DIExpression()
!31 = !DILocation(line: 37, column: 6, scope: !20)
!32 = !DILocalVariable(name: "QueueLength", scope: !20, file: !21, line: 38, type: !29)
!33 = !DILocation(line: 38, column: 6, scope: !20)
!34 = !DILocalVariable(name: "BlockSize", scope: !20, file: !21, line: 39, type: !29)
!35 = !DILocation(line: 39, column: 6, scope: !20)
!36 = !DILocalVariable(name: "myQueue", scope: !20, file: !21, line: 41, type: !37)
!37 = !DIDerivedType(tag: DW_TAG_typedef, name: "QueueHandle_t", file: !38, line: 47, baseType: !4)
!38 = !DIFile(filename: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp\5Cqueue.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!39 = !DILocation(line: 41, column: 16, scope: !20)
!40 = !DILocalVariable(name: "myQueueData", scope: !20, file: !21, line: 43, type: !41)
!41 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !42, size: 32, align: 32)
!42 = !DIDerivedType(tag: DW_TAG_typedef, name: "QueueData", file: !43, line: 31, baseType: !44)
!43 = !DIFile(filename: "../src/QueueTest.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!44 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "QueueData", file: !43, line: 25, size: 128, align: 32, elements: !45)
!45 = !{!46, !47, !48, !49}
!46 = !DIDerivedType(tag: DW_TAG_member, name: "inputQueue", scope: !44, file: !43, line: 27, baseType: !37, size: 32, align: 32)
!47 = !DIDerivedType(tag: DW_TAG_member, name: "outputQueue", scope: !44, file: !43, line: 28, baseType: !37, size: 32, align: 32, offset: 32)
!48 = !DIDerivedType(tag: DW_TAG_member, name: "queueLength", scope: !44, file: !43, line: 29, baseType: !29, size: 32, align: 32, offset: 64)
!49 = !DIDerivedType(tag: DW_TAG_member, name: "blockSize", scope: !44, file: !43, line: 30, baseType: !29, size: 32, align: 32, offset: 96)
!50 = !DILocation(line: 43, column: 13, scope: !20)
!51 = !DILocalVariable(name: "xReturned", scope: !20, file: !21, line: 45, type: !8)
!52 = !DILocation(line: 45, column: 13, scope: !20)
!53 = !DILocalVariable(name: "xBlabHandle", scope: !20, file: !21, line: 47, type: !54)
!54 = !DIDerivedType(tag: DW_TAG_typedef, name: "TaskHandle_t", file: !55, line: 62, baseType: !4)
!55 = !DIFile(filename: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp\5Ctask.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!56 = !DILocation(line: 47, column: 15, scope: !20)
!57 = !DILocalVariable(name: "xChatTXHandle", scope: !20, file: !21, line: 48, type: !54)
!58 = !DILocation(line: 48, column: 15, scope: !20)
!59 = !DILocalVariable(name: "xBlinkHandle", scope: !20, file: !21, line: 49, type: !54)
!60 = !DILocation(line: 49, column: 15, scope: !20)
!61 = !DILocalVariable(name: "xQSendHandle", scope: !20, file: !21, line: 50, type: !54)
!62 = !DILocation(line: 50, column: 15, scope: !20)
!63 = !DILocalVariable(name: "xQReceiveHandle", scope: !20, file: !21, line: 51, type: !54)
!64 = !DILocation(line: 51, column: 15, scope: !20)
!65 = !DILocation(line: 53, column: 2, scope: !20)
!66 = !DILocation(line: 58, column: 4, scope: !20)
!67 = !DILocation(line: 55, column: 14, scope: !20)
!68 = !DILocation(line: 55, column: 12, scope: !20)
!69 = !DILocation(line: 64, column: 6, scope: !70)
!70 = distinct !DILexicalBlock(scope: !20, file: !21, line: 64, column: 6)
!71 = !DILocation(line: 64, column: 16, scope: !70)
!72 = !DILocation(line: 64, column: 6, scope: !20)
!73 = !DILocation(line: 64, column: 27, scope: !74)
!74 = !DILexicalBlockFile(scope: !70, file: !21, discriminator: 1)
!75 = !DILocation(line: 69, column: 4, scope: !20)
!76 = !DILocation(line: 66, column: 14, scope: !20)
!77 = !DILocation(line: 66, column: 12, scope: !20)
!78 = !DILocation(line: 75, column: 6, scope: !79)
!79 = distinct !DILexicalBlock(scope: !20, file: !21, line: 75, column: 6)
!80 = !DILocation(line: 75, column: 16, scope: !79)
!81 = !DILocation(line: 75, column: 6, scope: !20)
!82 = !DILocation(line: 75, column: 27, scope: !83)
!83 = !DILexicalBlockFile(scope: !79, file: !21, discriminator: 1)
!84 = !DILocation(line: 80, column: 5, scope: !20)
!85 = !DILocation(line: 77, column: 14, scope: !20)
!86 = !DILocation(line: 77, column: 12, scope: !20)
!87 = !DILocation(line: 86, column: 6, scope: !88)
!88 = distinct !DILexicalBlock(scope: !20, file: !21, line: 86, column: 6)
!89 = !DILocation(line: 86, column: 16, scope: !88)
!90 = !DILocation(line: 86, column: 6, scope: !20)
!91 = !DILocation(line: 86, column: 27, scope: !92)
!92 = !DILexicalBlockFile(scope: !88, file: !21, discriminator: 1)
!93 = !DILocation(line: 91, column: 5, scope: !20)
!94 = !DILocation(line: 88, column: 14, scope: !20)
!95 = !DILocation(line: 88, column: 12, scope: !20)
!96 = !DILocation(line: 97, column: 6, scope: !97)
!97 = distinct !DILexicalBlock(scope: !20, file: !21, line: 97, column: 6)
!98 = !DILocation(line: 97, column: 16, scope: !97)
!99 = !DILocation(line: 97, column: 6, scope: !20)
!100 = !DILocation(line: 97, column: 27, scope: !101)
!101 = !DILexicalBlockFile(scope: !97, file: !21, discriminator: 1)
!102 = !DILocation(line: 108, column: 16, scope: !20)
!103 = !DILocation(line: 108, column: 14, scope: !20)
!104 = !DILocation(line: 110, column: 28, scope: !20)
!105 = !DILocation(line: 110, column: 2, scope: !20)
!106 = !DILocation(line: 110, column: 15, scope: !20)
!107 = !DILocation(line: 110, column: 26, scope: !20)
!108 = !DILocation(line: 111, column: 29, scope: !20)
!109 = !DILocation(line: 111, column: 2, scope: !20)
!110 = !DILocation(line: 111, column: 15, scope: !20)
!111 = !DILocation(line: 111, column: 27, scope: !20)
!112 = !DILocation(line: 112, column: 27, scope: !20)
!113 = !DILocation(line: 112, column: 2, scope: !20)
!114 = !DILocation(line: 112, column: 15, scope: !20)
!115 = !DILocation(line: 112, column: 25, scope: !20)
!116 = !DILocation(line: 117, column: 6, scope: !20)
!117 = !DILocation(line: 118, column: 15, scope: !20)
!118 = !DILocation(line: 118, column: 6, scope: !20)
!119 = !DILocation(line: 114, column: 14, scope: !20)
!120 = !DILocation(line: 114, column: 12, scope: !20)
!121 = !DILocation(line: 123, column: 6, scope: !122)
!122 = distinct !DILexicalBlock(scope: !20, file: !21, line: 123, column: 6)
!123 = !DILocation(line: 123, column: 16, scope: !122)
!124 = !DILocation(line: 123, column: 6, scope: !20)
!125 = !DILocation(line: 123, column: 27, scope: !126)
!126 = !DILexicalBlockFile(scope: !122, file: !21, discriminator: 1)
!127 = !DILocation(line: 128, column: 7, scope: !20)
!128 = !DILocation(line: 129, column: 16, scope: !20)
!129 = !DILocation(line: 129, column: 7, scope: !20)
!130 = !DILocation(line: 125, column: 14, scope: !20)
!131 = !DILocation(line: 125, column: 12, scope: !20)
!132 = !DILocation(line: 134, column: 6, scope: !133)
!133 = distinct !DILexicalBlock(scope: !20, file: !21, line: 134, column: 6)
!134 = !DILocation(line: 134, column: 16, scope: !133)
!135 = !DILocation(line: 134, column: 6, scope: !20)
!136 = !DILocation(line: 134, column: 27, scope: !137)
!137 = !DILexicalBlockFile(scope: !133, file: !21, discriminator: 1)
!138 = !DILocation(line: 137, column: 2, scope: !20)
!139 = !DILocation(line: 140, column: 2, scope: !20)
!140 = !{!"xil_printf"}
!141 = !{!"void.const char8 *.1"}
!142 = !{!"C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/xil_printf.h"}
!143 = !{!"xTaskCreate"}
!144 = !{!"BaseType_t.TaskFunction_t.1.const char *const.1.const uint16_t.0.void *const.1.UBaseType_t.0.TaskHandle_t *const.1"}
!145 = !{!"C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp\5Ctask.h"}
!146 = !{!"blabber"}
!147 = !{!"void.void *.1"}
!148 = !{!"../src/talky.h"}
!149 = distinct !DISubprogram(name: "printError", scope: !21, file: !21, line: 154, type: !22, isLocal: false, isDefinition: true, scopeLine: 155, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!150 = !{!"printError"}
!151 = !{!"C:/Users/TimothyDuke/workspace/ArtyFreeTest/src/dispatch.c"}
!152 = !DILocation(line: 156, column: 2, scope: !149)
!153 = !DILocation(line: 157, column: 1, scope: !149)
!154 = !{!"chatTX"}
!155 = !{!"blinky"}
!156 = !{!"SendTask"}
!157 = !{!"../src/QueueTest.h"}
!158 = !{!"pvPortMalloc"}
!159 = !{!"void .size_t.0"}
!160 = !{!"C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/portable.h"}
!161 = !{!"xQueueGenericCreate"}
!162 = !{!"QueueHandle_t.const UBaseType_t.0.const UBaseType_t.0.const uint8_t.0"}
!163 = !{!"C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp\5Cqueue.h"}
!164 = !{!"ReceiveTask"}
!165 = !{!"vTaskStartScheduler"}
!166 = distinct !DISubprogram(name: "continualDispatcher", scope: !21, file: !21, line: 148, type: !167, isLocal: false, isDefinition: true, scopeLine: 149, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!167 = !DISubroutineType(types: !168)
!168 = !{null, !4}
!169 = !{!"continualDispatcher"}
!170 = !DILocalVariable(name: "parameter", arg: 1, scope: !166, file: !21, line: 148, type: !4)
!171 = !DILocation(line: 148, column: 34, scope: !166)
!172 = !DILocation(line: 151, column: 2, scope: !166)
