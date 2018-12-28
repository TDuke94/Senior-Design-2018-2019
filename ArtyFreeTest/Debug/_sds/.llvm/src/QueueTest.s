; ModuleID = 'C:/Users/TimothyDuke/workspace/ArtyFreeTest/src/QueueTest.c'
source_filename = "C:/Users/TimothyDuke/workspace/ArtyFreeTest/src/QueueTest.c"
target datalayout = "e-m:e-p:32:32-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "armv7-none--eabi"

%struct.QueueData = type { i8*, i8*, i32, i32 }

@.str = private unnamed_addr constant [40 x i8] c"no parameters sent to SendTask()\0Aabort\0A\00", align 1
@myQueue = common global i8* null, align 4
@.str.1 = private unnamed_addr constant [43 x i8] c"no parameters sent to ReceiveTask()\0Aabort\0A\00", align 1

; Function Attrs: nounwind
define void @SendTask(i8*) #0 !dbg !35 !xidane.fname !38 !xidane.function_declaration_type !39 !xidane.function_declaration_filename !40 !xidane.ExternC !41 {
  %2 = alloca i8*, align 4
  %3 = alloca [30 x i8], align 1
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca %struct.QueueData, align 4
  store i8* %0, i8** %2, align 4
  call void @llvm.dbg.declare(metadata i8** %2, metadata !42, metadata !43), !dbg !44
  call void @llvm.dbg.declare(metadata [30 x i8]* %3, metadata !45, metadata !43), !dbg !49
  call void @llvm.dbg.declare(metadata i32* %4, metadata !50, metadata !43), !dbg !51
  call void @llvm.dbg.declare(metadata i32* %5, metadata !52, metadata !43), !dbg !53
  call void @llvm.dbg.declare(metadata i32* %6, metadata !54, metadata !43), !dbg !55
  call void @llvm.dbg.declare(metadata i32* %7, metadata !56, metadata !43), !dbg !57
  call void @llvm.dbg.declare(metadata %struct.QueueData* %8, metadata !58, metadata !43), !dbg !59
  %9 = load i8*, i8** %2, align 4, !dbg !60
  %10 = icmp eq i8* %9, null, !dbg !62
  br i1 %10, label %11, label %12, !dbg !63

; <label>:11:                                     ; preds = %1
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([40 x i8], [40 x i8]* @.str, i32 0, i32 0)), !dbg !64
  call void @vTaskDelete(i8* null), !dbg !66
  br label %12, !dbg !67

; <label>:12:                                     ; preds = %11, %1
  %13 = load i8*, i8** %2, align 4, !dbg !68
  %14 = bitcast i8* %13 to %struct.QueueData*, !dbg !69
  %15 = bitcast %struct.QueueData* %8 to i8*, !dbg !70
  %16 = bitcast %struct.QueueData* %14 to i8*, !dbg !70
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %15, i8* %16, i32 16, i32 4, i1 false), !dbg !70
  %17 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %8, i32 0, i32 0, !dbg !71
  %18 = load i8*, i8** %17, align 4, !dbg !71
  store i8* %18, i8** @myQueue, align 4, !dbg !72
  %19 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %8, i32 0, i32 2, !dbg !73
  %20 = load i32, i32* %19, align 4, !dbg !73
  store i32 %20, i32* %4, align 4, !dbg !74
  %21 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %8, i32 0, i32 3, !dbg !75
  %22 = load i32, i32* %21, align 4, !dbg !75
  store i32 %22, i32* %5, align 4, !dbg !76
  store i32 0, i32* %6, align 4, !dbg !77
  br label %23, !dbg !78

; <label>:23:                                     ; preds = %40, %12
  %24 = load i32, i32* %6, align 4, !dbg !79
  %25 = icmp eq i32 %24, 1, !dbg !84
  br i1 %25, label %26, label %27, !dbg !85

; <label>:26:                                     ; preds = %23
  store i32 0, i32* %6, align 4, !dbg !86
  call void @vTaskDelay(i32 200), !dbg !88
  br label %27, !dbg !89

; <label>:27:                                     ; preds = %26, %23
  store i32 0, i32* %7, align 4, !dbg !90
  br label %28, !dbg !92

; <label>:28:                                     ; preds = %37, %27
  %29 = load i32, i32* %7, align 4, !dbg !93
  %30 = icmp slt i32 %29, 10, !dbg !96
  br i1 %30, label %31, label %40, !dbg !97

; <label>:31:                                     ; preds = %28
  %32 = load i32, i32* %7, align 4, !dbg !98
  %33 = add nsw i32 %32, 65, !dbg !100
  %34 = trunc i32 %33 to i8, !dbg !101
  %35 = load i32, i32* %7, align 4, !dbg !102
  %36 = getelementptr inbounds [30 x i8], [30 x i8]* %3, i32 0, i32 %35, !dbg !103
  store i8 %34, i8* %36, align 1, !dbg !104
  br label %37, !dbg !105

; <label>:37:                                     ; preds = %31
  %38 = load i32, i32* %7, align 4, !dbg !106
  %39 = add nsw i32 %38, 1, !dbg !106
  store i32 %39, i32* %7, align 4, !dbg !106
  br label %28, !dbg !108, !llvm.loop !109

; <label>:40:                                     ; preds = %28
  %41 = load i8*, i8** @myQueue, align 4, !dbg !111
  %42 = getelementptr inbounds [30 x i8], [30 x i8]* %3, i32 0, i32 0, !dbg !111
  %43 = call i32 @xQueueGenericSend(i8* %41, i8* %42, i32 0, i32 0), !dbg !111
  br label %23, !dbg !112, !llvm.loop !114
                                                  ; No predecessors!
  ret void, !dbg !115
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

declare !xidane.fname !116 !xidane.function_declaration_type !117 !xidane.function_declaration_filename !118 !xidane.ExternC !41 void @xil_printf(i8*, ...) #2

declare !xidane.fname !119 !xidane.function_declaration_type !120 !xidane.function_declaration_filename !121 !xidane.ExternC !41 void @vTaskDelete(i8*) #2

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i32(i8* nocapture writeonly, i8* nocapture readonly, i32, i32, i1) #3

declare !xidane.fname !122 !xidane.function_declaration_type !123 !xidane.function_declaration_filename !121 !xidane.ExternC !41 void @vTaskDelay(i32) #2

declare !xidane.fname !124 !xidane.function_declaration_type !125 !xidane.function_declaration_filename !126 !xidane.ExternC !41 i32 @xQueueGenericSend(i8*, i8*, i32, i32) #2

; Function Attrs: nounwind
define void @ReceiveTask(i8*) #0 !dbg !127 !xidane.fname !128 !xidane.function_declaration_type !39 !xidane.function_declaration_filename !40 !xidane.ExternC !41 {
  %2 = alloca i8*, align 4
  %3 = alloca [30 x i8], align 1
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca %struct.QueueData, align 4
  store i8* %0, i8** %2, align 4
  call void @llvm.dbg.declare(metadata i8** %2, metadata !129, metadata !43), !dbg !130
  call void @llvm.dbg.declare(metadata [30 x i8]* %3, metadata !131, metadata !43), !dbg !132
  call void @llvm.dbg.declare(metadata i32* %4, metadata !133, metadata !43), !dbg !134
  call void @llvm.dbg.declare(metadata i32* %5, metadata !135, metadata !43), !dbg !136
  call void @llvm.dbg.declare(metadata i32* %6, metadata !137, metadata !43), !dbg !138
  call void @llvm.dbg.declare(metadata %struct.QueueData* %7, metadata !139, metadata !43), !dbg !140
  %8 = load i8*, i8** %2, align 4, !dbg !141
  %9 = icmp eq i8* %8, null, !dbg !143
  br i1 %9, label %10, label %11, !dbg !144

; <label>:10:                                     ; preds = %1
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([43 x i8], [43 x i8]* @.str.1, i32 0, i32 0)), !dbg !145
  call void @vTaskDelete(i8* null), !dbg !147
  br label %11, !dbg !148

; <label>:11:                                     ; preds = %10, %1
  %12 = load i8*, i8** %2, align 4, !dbg !149
  %13 = bitcast i8* %12 to %struct.QueueData*, !dbg !150
  %14 = bitcast %struct.QueueData* %7 to i8*, !dbg !151
  %15 = bitcast %struct.QueueData* %13 to i8*, !dbg !151
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %14, i8* %15, i32 16, i32 4, i1 false), !dbg !151
  %16 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %7, i32 0, i32 0, !dbg !152
  %17 = load i8*, i8** %16, align 4, !dbg !152
  store i8* %17, i8** @myQueue, align 4, !dbg !153
  %18 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %7, i32 0, i32 2, !dbg !154
  %19 = load i32, i32* %18, align 4, !dbg !154
  store i32 %19, i32* %4, align 4, !dbg !155
  %20 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %7, i32 0, i32 3, !dbg !156
  %21 = load i32, i32* %20, align 4, !dbg !156
  store i32 %21, i32* %5, align 4, !dbg !157
  store i32 1, i32* %6, align 4, !dbg !158
  br label %22, !dbg !159

; <label>:22:                                     ; preds = %30, %29, %11
  %23 = load i32, i32* %6, align 4, !dbg !160
  %24 = icmp eq i32 %23, 1, !dbg !165
  br i1 %24, label %25, label %26, !dbg !166

; <label>:25:                                     ; preds = %22
  store i32 0, i32* %6, align 4, !dbg !167
  call void @vTaskDelay(i32 200), !dbg !169
  br label %26, !dbg !170

; <label>:26:                                     ; preds = %25, %22
  %27 = load i8*, i8** @myQueue, align 4, !dbg !171
  %28 = icmp eq i8* %27, null, !dbg !173
  br i1 %28, label %29, label %30, !dbg !174

; <label>:29:                                     ; preds = %26
  store i32 1, i32* %6, align 4, !dbg !175
  br label %22, !dbg !177, !llvm.loop !178

; <label>:30:                                     ; preds = %26
  %31 = load i8*, i8** @myQueue, align 4, !dbg !179
  %32 = getelementptr inbounds [30 x i8], [30 x i8]* %3, i32 0, i32 0, !dbg !180
  %33 = call i32 @xQueueReceive(i8* %31, i8* %32, i32 5), !dbg !181
  %34 = getelementptr inbounds [30 x i8], [30 x i8]* %3, i32 0, i32 0, !dbg !182
  call void (i8*, ...) @xil_printf(i8* %34), !dbg !183
  br label %22, !dbg !184, !llvm.loop !178
                                                  ; No predecessors!
  ret void, !dbg !186
}

declare !xidane.fname !187 !xidane.function_declaration_type !188 !xidane.function_declaration_filename !126 !xidane.ExternC !41 i32 @xQueueReceive(i8*, i8*, i32) #2

attributes #0 = { nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-a9" "target-features"="+dsp,+strict-align,+vfp3,-crypto,-d16,-fp-armv8,-fp-only-sp,-fp16,-neon,-vfp4" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-a9" "target-features"="+dsp,+strict-align,+vfp3,-crypto,-d16,-fp-armv8,-fp-only-sp,-fp16,-neon,-vfp4" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { argmemonly nounwind }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!30, !31, !32, !33}
!llvm.ident = !{!34}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 3.9.0 (tags/RELEASE_390/final)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !3, globals: !27)
!1 = !DIFile(filename: "../src\5CQueueTest.c", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!2 = !{}
!3 = !{!4, !5, !17, !18, !25}
!4 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 32, align: 32)
!5 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !6, size: 32, align: 32)
!6 = !DIDerivedType(tag: DW_TAG_typedef, name: "QueueData", file: !7, line: 31, baseType: !8)
!7 = !DIFile(filename: "../src/QueueTest.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!8 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "QueueData", file: !7, line: 25, size: 128, align: 32, elements: !9)
!9 = !{!10, !13, !14, !16}
!10 = !DIDerivedType(tag: DW_TAG_member, name: "inputQueue", scope: !8, file: !7, line: 27, baseType: !11, size: 32, align: 32)
!11 = !DIDerivedType(tag: DW_TAG_typedef, name: "QueueHandle_t", file: !12, line: 47, baseType: !4)
!12 = !DIFile(filename: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp\5Cqueue.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!13 = !DIDerivedType(tag: DW_TAG_member, name: "outputQueue", scope: !8, file: !7, line: 28, baseType: !11, size: 32, align: 32, offset: 32)
!14 = !DIDerivedType(tag: DW_TAG_member, name: "queueLength", scope: !8, file: !7, line: 29, baseType: !15, size: 32, align: 32, offset: 64)
!15 = !DIBasicType(name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!16 = !DIDerivedType(tag: DW_TAG_member, name: "blockSize", scope: !8, file: !7, line: 30, baseType: !15, size: 32, align: 32, offset: 96)
!17 = !DIBasicType(name: "char", size: 8, align: 8, encoding: DW_ATE_unsigned_char)
!18 = !DIDerivedType(tag: DW_TAG_typedef, name: "TickType_t", file: !19, line: 62, baseType: !20)
!19 = !DIFile(filename: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/portmacro.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!20 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !21, line: 32, baseType: !22)
!21 = !DIFile(filename: "E:/SDSoC/SDK/2018.2/gnu/aarch32/nt/gcc-arm-none-eabi/arm-none-eabi/libc/usr/include\5Csys/_stdint.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!22 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint32_t", file: !23, line: 65, baseType: !24)
!23 = !DIFile(filename: "E:/SDSoC/SDK/2018.2/gnu/aarch32/nt/gcc-arm-none-eabi/arm-none-eabi/libc/usr/include\5Cmachine/_default_types.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!24 = !DIBasicType(name: "unsigned int", size: 32, align: 32, encoding: DW_ATE_unsigned)
!25 = !DIDerivedType(tag: DW_TAG_typedef, name: "BaseType_t", file: !19, line: 59, baseType: !26)
!26 = !DIBasicType(name: "long int", size: 32, align: 32, encoding: DW_ATE_signed)
!27 = !{!28}
!28 = distinct !DIGlobalVariable(name: "myQueue", scope: !0, file: !29, line: 24, type: !11, isLocal: false, isDefinition: true, variable: i8** @myQueue)
!29 = !DIFile(filename: "C:/Users/TimothyDuke/workspace/ArtyFreeTest/src/QueueTest.c", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!30 = !{i32 2, !"Dwarf Version", i32 4}
!31 = !{i32 2, !"Debug Info Version", i32 3}
!32 = !{i32 1, !"wchar_size", i32 4}
!33 = !{i32 1, !"min_enum_size", i32 4}
!34 = !{!"clang version 3.9.0 (tags/RELEASE_390/final)"}
!35 = distinct !DISubprogram(name: "SendTask", scope: !29, file: !29, line: 38, type: !36, isLocal: false, isDefinition: true, scopeLine: 39, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!36 = !DISubroutineType(types: !37)
!37 = !{null, !4}
!38 = !{!"SendTask"}
!39 = !{!"void.void *.1"}
!40 = !{!"../src/QueueTest.h"}
!41 = !{!"t"}
!42 = !DILocalVariable(name: "parameters", arg: 1, scope: !35, file: !29, line: 38, type: !4)
!43 = !DIExpression()
!44 = !DILocation(line: 38, column: 21, scope: !35)
!45 = !DILocalVariable(name: "TXBuffer", scope: !35, file: !29, line: 40, type: !46)
!46 = !DICompositeType(tag: DW_TAG_array_type, baseType: !17, size: 240, align: 8, elements: !47)
!47 = !{!48}
!48 = !DISubrange(count: 30)
!49 = !DILocation(line: 40, column: 7, scope: !35)
!50 = !DILocalVariable(name: "queueLength", scope: !35, file: !29, line: 41, type: !15)
!51 = !DILocation(line: 41, column: 6, scope: !35)
!52 = !DILocalVariable(name: "blockSize", scope: !35, file: !29, line: 41, type: !15)
!53 = !DILocation(line: 41, column: 19, scope: !35)
!54 = !DILocalVariable(name: "DelayFlag", scope: !35, file: !29, line: 41, type: !15)
!55 = !DILocation(line: 41, column: 30, scope: !35)
!56 = !DILocalVariable(name: "i", scope: !35, file: !29, line: 41, type: !15)
!57 = !DILocation(line: 41, column: 41, scope: !35)
!58 = !DILocalVariable(name: "myQueueData", scope: !35, file: !29, line: 42, type: !6)
!59 = !DILocation(line: 42, column: 12, scope: !35)
!60 = !DILocation(line: 44, column: 6, scope: !61)
!61 = distinct !DILexicalBlock(scope: !35, file: !29, line: 44, column: 6)
!62 = !DILocation(line: 44, column: 17, scope: !61)
!63 = !DILocation(line: 44, column: 6, scope: !35)
!64 = !DILocation(line: 46, column: 3, scope: !65)
!65 = distinct !DILexicalBlock(scope: !61, file: !29, line: 45, column: 2)
!66 = !DILocation(line: 47, column: 3, scope: !65)
!67 = !DILocation(line: 48, column: 2, scope: !65)
!68 = !DILocation(line: 50, column: 32, scope: !35)
!69 = !DILocation(line: 50, column: 18, scope: !35)
!70 = !DILocation(line: 50, column: 16, scope: !35)
!71 = !DILocation(line: 52, column: 24, scope: !35)
!72 = !DILocation(line: 52, column: 10, scope: !35)
!73 = !DILocation(line: 53, column: 28, scope: !35)
!74 = !DILocation(line: 53, column: 14, scope: !35)
!75 = !DILocation(line: 54, column: 26, scope: !35)
!76 = !DILocation(line: 54, column: 12, scope: !35)
!77 = !DILocation(line: 57, column: 12, scope: !35)
!78 = !DILocation(line: 59, column: 2, scope: !35)
!79 = !DILocation(line: 62, column: 7, scope: !80)
!80 = distinct !DILexicalBlock(scope: !81, file: !29, line: 62, column: 7)
!81 = distinct !DILexicalBlock(scope: !82, file: !29, line: 60, column: 2)
!82 = distinct !DILexicalBlock(scope: !83, file: !29, line: 59, column: 2)
!83 = distinct !DILexicalBlock(scope: !35, file: !29, line: 59, column: 2)
!84 = !DILocation(line: 62, column: 17, scope: !80)
!85 = !DILocation(line: 62, column: 7, scope: !81)
!86 = !DILocation(line: 65, column: 14, scope: !87)
!87 = distinct !DILexicalBlock(scope: !80, file: !29, line: 63, column: 3)
!88 = !DILocation(line: 68, column: 4, scope: !87)
!89 = !DILocation(line: 69, column: 3, scope: !87)
!90 = !DILocation(line: 81, column: 10, scope: !91)
!91 = distinct !DILexicalBlock(scope: !81, file: !29, line: 81, column: 3)
!92 = !DILocation(line: 81, column: 8, scope: !91)
!93 = !DILocation(line: 81, column: 15, scope: !94)
!94 = !DILexicalBlockFile(scope: !95, file: !29, discriminator: 1)
!95 = distinct !DILexicalBlock(scope: !91, file: !29, line: 81, column: 3)
!96 = !DILocation(line: 81, column: 17, scope: !94)
!97 = !DILocation(line: 81, column: 3, scope: !94)
!98 = !DILocation(line: 83, column: 26, scope: !99)
!99 = distinct !DILexicalBlock(scope: !95, file: !29, line: 82, column: 3)
!100 = !DILocation(line: 83, column: 28, scope: !99)
!101 = !DILocation(line: 83, column: 18, scope: !99)
!102 = !DILocation(line: 83, column: 13, scope: !99)
!103 = !DILocation(line: 83, column: 4, scope: !99)
!104 = !DILocation(line: 83, column: 16, scope: !99)
!105 = !DILocation(line: 84, column: 3, scope: !99)
!106 = !DILocation(line: 81, column: 24, scope: !107)
!107 = !DILexicalBlockFile(scope: !95, file: !29, discriminator: 2)
!108 = !DILocation(line: 81, column: 3, scope: !107)
!109 = distinct !{!109, !110}
!110 = !DILocation(line: 81, column: 3, scope: !81)
!111 = !DILocation(line: 86, column: 3, scope: !81)
!112 = !DILocation(line: 59, column: 2, scope: !113)
!113 = !DILexicalBlockFile(scope: !82, file: !29, discriminator: 1)
!114 = distinct !{!114, !78}
!115 = !DILocation(line: 98, column: 1, scope: !35)
!116 = !{!"xil_printf"}
!117 = !{!"void.const char8 *.1"}
!118 = !{!"C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/xil_printf.h"}
!119 = !{!"vTaskDelete"}
!120 = !{!"void.TaskHandle_t.1"}
!121 = !{!"C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp\5Ctask.h"}
!122 = !{!"vTaskDelay"}
!123 = !{!"void.const TickType_t.0"}
!124 = !{!"xQueueGenericSend"}
!125 = !{!"BaseType_t.QueueHandle_t.1.const void *const.1.TickType_t.0.const BaseType_t.0"}
!126 = !{!"C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp\5Cqueue.h"}
!127 = distinct !DISubprogram(name: "ReceiveTask", scope: !29, file: !29, line: 110, type: !36, isLocal: false, isDefinition: true, scopeLine: 111, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!128 = !{!"ReceiveTask"}
!129 = !DILocalVariable(name: "parameters", arg: 1, scope: !127, file: !29, line: 110, type: !4)
!130 = !DILocation(line: 110, column: 24, scope: !127)
!131 = !DILocalVariable(name: "RXBuffer", scope: !127, file: !29, line: 112, type: !46)
!132 = !DILocation(line: 112, column: 7, scope: !127)
!133 = !DILocalVariable(name: "queueLength", scope: !127, file: !29, line: 113, type: !15)
!134 = !DILocation(line: 113, column: 6, scope: !127)
!135 = !DILocalVariable(name: "blockSize", scope: !127, file: !29, line: 113, type: !15)
!136 = !DILocation(line: 113, column: 19, scope: !127)
!137 = !DILocalVariable(name: "DelayFlag", scope: !127, file: !29, line: 113, type: !15)
!138 = !DILocation(line: 113, column: 30, scope: !127)
!139 = !DILocalVariable(name: "myQueueData", scope: !127, file: !29, line: 114, type: !6)
!140 = !DILocation(line: 114, column: 12, scope: !127)
!141 = !DILocation(line: 116, column: 6, scope: !142)
!142 = distinct !DILexicalBlock(scope: !127, file: !29, line: 116, column: 6)
!143 = !DILocation(line: 116, column: 17, scope: !142)
!144 = !DILocation(line: 116, column: 6, scope: !127)
!145 = !DILocation(line: 118, column: 3, scope: !146)
!146 = distinct !DILexicalBlock(scope: !142, file: !29, line: 117, column: 2)
!147 = !DILocation(line: 119, column: 3, scope: !146)
!148 = !DILocation(line: 120, column: 2, scope: !146)
!149 = !DILocation(line: 122, column: 32, scope: !127)
!150 = !DILocation(line: 122, column: 18, scope: !127)
!151 = !DILocation(line: 122, column: 16, scope: !127)
!152 = !DILocation(line: 124, column: 24, scope: !127)
!153 = !DILocation(line: 124, column: 10, scope: !127)
!154 = !DILocation(line: 125, column: 28, scope: !127)
!155 = !DILocation(line: 125, column: 14, scope: !127)
!156 = !DILocation(line: 126, column: 26, scope: !127)
!157 = !DILocation(line: 126, column: 12, scope: !127)
!158 = !DILocation(line: 129, column: 12, scope: !127)
!159 = !DILocation(line: 131, column: 2, scope: !127)
!160 = !DILocation(line: 134, column: 6, scope: !161)
!161 = distinct !DILexicalBlock(scope: !162, file: !29, line: 134, column: 6)
!162 = distinct !DILexicalBlock(scope: !163, file: !29, line: 132, column: 2)
!163 = distinct !DILexicalBlock(scope: !164, file: !29, line: 131, column: 2)
!164 = distinct !DILexicalBlock(scope: !127, file: !29, line: 131, column: 2)
!165 = !DILocation(line: 134, column: 16, scope: !161)
!166 = !DILocation(line: 134, column: 6, scope: !162)
!167 = !DILocation(line: 137, column: 14, scope: !168)
!168 = distinct !DILexicalBlock(scope: !161, file: !29, line: 135, column: 3)
!169 = !DILocation(line: 139, column: 4, scope: !168)
!170 = !DILocation(line: 140, column: 3, scope: !168)
!171 = !DILocation(line: 143, column: 7, scope: !172)
!172 = distinct !DILexicalBlock(scope: !162, file: !29, line: 143, column: 7)
!173 = !DILocation(line: 143, column: 15, scope: !172)
!174 = !DILocation(line: 143, column: 7, scope: !162)
!175 = !DILocation(line: 146, column: 14, scope: !176)
!176 = distinct !DILexicalBlock(scope: !172, file: !29, line: 144, column: 3)
!177 = !DILocation(line: 149, column: 4, scope: !176)
!178 = distinct !{!178, !159}
!179 = !DILocation(line: 153, column: 18, scope: !162)
!180 = !DILocation(line: 153, column: 35, scope: !162)
!181 = !DILocation(line: 153, column: 3, scope: !162)
!182 = !DILocation(line: 156, column: 14, scope: !162)
!183 = !DILocation(line: 156, column: 3, scope: !162)
!184 = !DILocation(line: 131, column: 2, scope: !185)
!185 = !DILexicalBlockFile(scope: !163, file: !29, discriminator: 1)
!186 = !DILocation(line: 167, column: 1, scope: !127)
!187 = !{!"xQueueReceive"}
!188 = !{!"BaseType_t.QueueHandle_t.1.void *const.1.TickType_t.0"}
