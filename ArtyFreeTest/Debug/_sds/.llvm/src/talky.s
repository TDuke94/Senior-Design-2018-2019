; ModuleID = 'C:/Users/TimothyDuke/workspace/ArtyFreeTest/src/talky.c'
source_filename = "C:/Users/TimothyDuke/workspace/ArtyFreeTest/src/talky.c"
target datalayout = "e-m:e-p:32:32-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "armv7-none--eabi"

%struct.XGpio = type { i32, i32, i32, i32 }

@.str = private unnamed_addr constant [17 x i8] c"GPIO Init Error\0A\00", align 1

; Function Attrs: nounwind
define void @blabber(i8*) #0 !dbg !10 !xidane.fname !14 !xidane.function_declaration_type !15 !xidane.function_declaration_filename !16 !xidane.ExternC !17 {
  %2 = alloca i8*, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  store i8* %0, i8** %2, align 4
  call void @llvm.dbg.declare(metadata i8** %2, metadata !18, metadata !19), !dbg !20
  call void @llvm.dbg.declare(metadata i32* %3, metadata !21, metadata !19), !dbg !23
  call void @llvm.dbg.declare(metadata i32* %4, metadata !24, metadata !19), !dbg !25
  %5 = load i8*, i8** %2, align 4, !dbg !26
  %6 = icmp ne i8* %5, null, !dbg !28
  br i1 %6, label %7, label %8, !dbg !29

; <label>:7:                                      ; preds = %1
  store i32 0, i32* %4, align 4, !dbg !30
  br label %8, !dbg !32

; <label>:8:                                      ; preds = %7, %1
  store i32 10, i32* %3, align 4, !dbg !33
  br label %9, !dbg !34

; <label>:9:                                      ; preds = %26, %8
  store i32 1, i32* %4, align 4, !dbg !35
  br label %10, !dbg !40

; <label>:10:                                     ; preds = %15, %9
  %11 = load i32, i32* %4, align 4, !dbg !41
  %12 = load i32, i32* %3, align 4, !dbg !44
  %13 = icmp sle i32 %11, %12, !dbg !45
  br i1 %13, label %14, label %18, !dbg !46

; <label>:14:                                     ; preds = %10
  br label %15, !dbg !47

; <label>:15:                                     ; preds = %14
  %16 = load i32, i32* %4, align 4, !dbg !49
  %17 = add nsw i32 %16, 1, !dbg !49
  store i32 %17, i32* %4, align 4, !dbg !49
  br label %10, !dbg !51, !llvm.loop !52

; <label>:18:                                     ; preds = %10
  store i32 0, i32* %4, align 4, !dbg !54
  br label %19, !dbg !56

; <label>:19:                                     ; preds = %23, %18
  %20 = load i32, i32* %4, align 4, !dbg !57
  %21 = icmp slt i32 %20, 10000, !dbg !60
  br i1 %21, label %22, label %26, !dbg !61

; <label>:22:                                     ; preds = %19
  br label %23, !dbg !62

; <label>:23:                                     ; preds = %22
  %24 = load i32, i32* %4, align 4, !dbg !64
  %25 = add nsw i32 %24, 1, !dbg !64
  store i32 %25, i32* %4, align 4, !dbg !64
  br label %19, !dbg !66, !llvm.loop !67

; <label>:26:                                     ; preds = %19
  br label %9, !dbg !69, !llvm.loop !71
                                                  ; No predecessors!
  ret void, !dbg !72
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: nounwind
define void @chatTX(i8*) #0 !dbg !73 !xidane.fname !74 !xidane.function_declaration_type !15 !xidane.function_declaration_filename !16 !xidane.ExternC !17 {
  %2 = alloca i8*, align 4
  %3 = alloca i32, align 4
  store i8* %0, i8** %2, align 4
  call void @llvm.dbg.declare(metadata i8** %2, metadata !75, metadata !19), !dbg !76
  call void @llvm.dbg.declare(metadata i32* %3, metadata !77, metadata !19), !dbg !78
  %4 = load i8*, i8** %2, align 4, !dbg !79
  %5 = icmp eq i8* %4, null, !dbg !81
  br i1 %5, label %6, label %7, !dbg !82

; <label>:6:                                      ; preds = %1
  store i32 0, i32* %3, align 4, !dbg !83
  br label %7, !dbg !85

; <label>:7:                                      ; preds = %6, %1
  br label %8, !dbg !86

; <label>:8:                                      ; preds = %8, %7
  br label %8, !dbg !87, !llvm.loop !91
                                                  ; No predecessors!
  ret void, !dbg !92
}

; Function Attrs: nounwind
define void @chatRX(i8*) #0 !dbg !93 !xidane.fname !94 !xidane.function_declaration_type !15 !xidane.function_declaration_filename !16 !xidane.ExternC !17 {
  %2 = alloca i8*, align 4
  %3 = alloca i32, align 4
  store i8* %0, i8** %2, align 4
  call void @llvm.dbg.declare(metadata i8** %2, metadata !95, metadata !19), !dbg !96
  call void @llvm.dbg.declare(metadata i32* %3, metadata !97, metadata !19), !dbg !98
  %4 = load i8*, i8** %2, align 4, !dbg !99
  %5 = icmp eq i8* %4, null, !dbg !101
  br i1 %5, label %6, label %7, !dbg !102

; <label>:6:                                      ; preds = %1
  store i32 0, i32* %3, align 4, !dbg !103
  br label %7, !dbg !105

; <label>:7:                                      ; preds = %6, %1
  br label %8, !dbg !106

; <label>:8:                                      ; preds = %8, %7
  br label %8, !dbg !107, !llvm.loop !111
                                                  ; No predecessors!
  ret void, !dbg !112
}

; Function Attrs: nounwind
define void @blinky(i8*) #0 !dbg !113 !xidane.fname !114 !xidane.function_declaration_type !15 !xidane.function_declaration_filename !16 !xidane.ExternC !17 {
  %2 = alloca i8*, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca %struct.XGpio, align 4
  %7 = alloca i32, align 4
  store i8* %0, i8** %2, align 4
  call void @llvm.dbg.declare(metadata i8** %2, metadata !115, metadata !19), !dbg !116
  call void @llvm.dbg.declare(metadata i32* %3, metadata !117, metadata !19), !dbg !118
  call void @llvm.dbg.declare(metadata i32* %4, metadata !119, metadata !19), !dbg !120
  call void @llvm.dbg.declare(metadata i32* %5, metadata !121, metadata !19), !dbg !123
  call void @llvm.dbg.declare(metadata %struct.XGpio* %6, metadata !124, metadata !19), !dbg !144
  call void @llvm.dbg.declare(metadata i32* %7, metadata !145, metadata !19), !dbg !146
  %8 = load i8*, i8** %2, align 4, !dbg !147
  %9 = icmp eq i8* %8, null, !dbg !149
  br i1 %9, label %10, label %11, !dbg !150

; <label>:10:                                     ; preds = %1
  store i32 0, i32* %3, align 4, !dbg !151
  br label %11, !dbg !153

; <label>:11:                                     ; preds = %10, %1
  %12 = call i32 @XGpio_Initialize(%struct.XGpio* %6, i16 zeroext 1), !dbg !154
  store i32 %12, i32* %7, align 4, !dbg !155
  %13 = load i32, i32* %7, align 4, !dbg !156
  %14 = icmp ne i32 %13, 0, !dbg !158
  br i1 %14, label %15, label %16, !dbg !159

; <label>:15:                                     ; preds = %11
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str, i32 0, i32 0)), !dbg !160
  ret void, !dbg !162

; <label>:16:                                     ; preds = %11
  call void @XGpio_SetDataDirection(%struct.XGpio* %6, i32 1, i32 -256), !dbg !163
  store i32 0, i32* %4, align 4, !dbg !164
  br label %17, !dbg !165

; <label>:17:                                     ; preds = %32, %16
  store i32 0, i32* %3, align 4, !dbg !166
  br label %18, !dbg !171

; <label>:18:                                     ; preds = %22, %17
  %19 = load i32, i32* %3, align 4, !dbg !172
  %20 = icmp slt i32 %19, 100000, !dbg !175
  br i1 %20, label %21, label %25, !dbg !176

; <label>:21:                                     ; preds = %18
  store volatile i32 0, i32* %5, align 4, !dbg !177
  br label %22, !dbg !179

; <label>:22:                                     ; preds = %21
  %23 = load i32, i32* %3, align 4, !dbg !180
  %24 = add nsw i32 %23, 1, !dbg !180
  store i32 %24, i32* %3, align 4, !dbg !180
  br label %18, !dbg !182, !llvm.loop !183

; <label>:25:                                     ; preds = %18
  %26 = load i32, i32* %4, align 4, !dbg !185
  %27 = icmp eq i32 %26, 0, !dbg !187
  br i1 %27, label %28, label %31, !dbg !188

; <label>:28:                                     ; preds = %25
  call void @XGpio_DiscreteWrite(%struct.XGpio* %6, i32 1, i32 255), !dbg !189
  %29 = load i32, i32* %4, align 4, !dbg !191
  %30 = add nsw i32 %29, 1, !dbg !191
  store i32 %30, i32* %4, align 4, !dbg !191
  br label %32, !dbg !192

; <label>:31:                                     ; preds = %25
  store i32 0, i32* %4, align 4, !dbg !193
  call void @XGpio_DiscreteClear(%struct.XGpio* %6, i32 1, i32 255), !dbg !195
  br label %32

; <label>:32:                                     ; preds = %31, %28
  br label %17, !dbg !196, !llvm.loop !198
}

declare !xidane.fname !199 !xidane.function_declaration_type !200 !xidane.function_declaration_filename !201 !xidane.ExternC !17 i32 @XGpio_Initialize(%struct.XGpio*, i16 zeroext) #2

declare !xidane.fname !202 !xidane.function_declaration_type !203 !xidane.function_declaration_filename !204 !xidane.ExternC !17 void @xil_printf(i8*, ...) #2

declare !xidane.fname !205 !xidane.function_declaration_type !206 !xidane.function_declaration_filename !201 !xidane.ExternC !17 void @XGpio_SetDataDirection(%struct.XGpio*, i32, i32) #2

declare !xidane.fname !207 !xidane.function_declaration_type !206 !xidane.function_declaration_filename !201 !xidane.ExternC !17 void @XGpio_DiscreteWrite(%struct.XGpio*, i32, i32) #2

declare !xidane.fname !208 !xidane.function_declaration_type !206 !xidane.function_declaration_filename !201 !xidane.ExternC !17 void @XGpio_DiscreteClear(%struct.XGpio*, i32, i32) #2

attributes #0 = { nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-a9" "target-features"="+dsp,+strict-align,+vfp3,-crypto,-d16,-fp-armv8,-fp-only-sp,-fp16,-neon,-vfp4" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-a9" "target-features"="+dsp,+strict-align,+vfp3,-crypto,-d16,-fp-armv8,-fp-only-sp,-fp16,-neon,-vfp4" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!5, !6, !7, !8}
!llvm.ident = !{!9}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 3.9.0 (tags/RELEASE_390/final)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !3)
!1 = !DIFile(filename: "../src\5Ctalky.c", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!2 = !{}
!3 = !{!4}
!4 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 32, align: 32)
!5 = !{i32 2, !"Dwarf Version", i32 4}
!6 = !{i32 2, !"Debug Info Version", i32 3}
!7 = !{i32 1, !"wchar_size", i32 4}
!8 = !{i32 1, !"min_enum_size", i32 4}
!9 = !{!"clang version 3.9.0 (tags/RELEASE_390/final)"}
!10 = distinct !DISubprogram(name: "blabber", scope: !11, file: !11, line: 31, type: !12, isLocal: false, isDefinition: true, scopeLine: 32, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!11 = !DIFile(filename: "C:/Users/TimothyDuke/workspace/ArtyFreeTest/src/talky.c", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!12 = !DISubroutineType(types: !13)
!13 = !{null, !4}
!14 = !{!"blabber"}
!15 = !{!"void.void *.1"}
!16 = !{!"../src/talky.h"}
!17 = !{!"t"}
!18 = !DILocalVariable(name: "parameters", arg: 1, scope: !10, file: !11, line: 31, type: !4)
!19 = !DIExpression()
!20 = !DILocation(line: 31, column: 22, scope: !10)
!21 = !DILocalVariable(name: "loop", scope: !10, file: !11, line: 34, type: !22)
!22 = !DIBasicType(name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!23 = !DILocation(line: 34, column: 6, scope: !10)
!24 = !DILocalVariable(name: "i", scope: !10, file: !11, line: 34, type: !22)
!25 = !DILocation(line: 34, column: 12, scope: !10)
!26 = !DILocation(line: 36, column: 6, scope: !27)
!27 = distinct !DILexicalBlock(scope: !10, file: !11, line: 36, column: 6)
!28 = !DILocation(line: 36, column: 17, scope: !27)
!29 = !DILocation(line: 36, column: 6, scope: !10)
!30 = !DILocation(line: 39, column: 5, scope: !31)
!31 = distinct !DILexicalBlock(scope: !27, file: !11, line: 37, column: 2)
!32 = !DILocation(line: 40, column: 2, scope: !31)
!33 = !DILocation(line: 42, column: 7, scope: !10)
!34 = !DILocation(line: 44, column: 2, scope: !10)
!35 = !DILocation(line: 46, column: 10, scope: !36)
!36 = distinct !DILexicalBlock(scope: !37, file: !11, line: 46, column: 3)
!37 = distinct !DILexicalBlock(scope: !38, file: !11, line: 45, column: 2)
!38 = distinct !DILexicalBlock(scope: !39, file: !11, line: 44, column: 2)
!39 = distinct !DILexicalBlock(scope: !10, file: !11, line: 44, column: 2)
!40 = !DILocation(line: 46, column: 8, scope: !36)
!41 = !DILocation(line: 46, column: 15, scope: !42)
!42 = !DILexicalBlockFile(scope: !43, file: !11, discriminator: 1)
!43 = distinct !DILexicalBlock(scope: !36, file: !11, line: 46, column: 3)
!44 = !DILocation(line: 46, column: 20, scope: !42)
!45 = !DILocation(line: 46, column: 17, scope: !42)
!46 = !DILocation(line: 46, column: 3, scope: !42)
!47 = !DILocation(line: 49, column: 3, scope: !48)
!48 = distinct !DILexicalBlock(scope: !43, file: !11, line: 47, column: 3)
!49 = !DILocation(line: 46, column: 27, scope: !50)
!50 = !DILexicalBlockFile(scope: !43, file: !11, discriminator: 2)
!51 = !DILocation(line: 46, column: 3, scope: !50)
!52 = distinct !{!52, !53}
!53 = !DILocation(line: 46, column: 3, scope: !37)
!54 = !DILocation(line: 51, column: 10, scope: !55)
!55 = distinct !DILexicalBlock(scope: !37, file: !11, line: 51, column: 3)
!56 = !DILocation(line: 51, column: 8, scope: !55)
!57 = !DILocation(line: 51, column: 15, scope: !58)
!58 = !DILexicalBlockFile(scope: !59, file: !11, discriminator: 1)
!59 = distinct !DILexicalBlock(scope: !55, file: !11, line: 51, column: 3)
!60 = !DILocation(line: 51, column: 17, scope: !58)
!61 = !DILocation(line: 51, column: 3, scope: !58)
!62 = !DILocation(line: 54, column: 3, scope: !63)
!63 = distinct !DILexicalBlock(scope: !59, file: !11, line: 52, column: 3)
!64 = !DILocation(line: 51, column: 27, scope: !65)
!65 = !DILexicalBlockFile(scope: !59, file: !11, discriminator: 2)
!66 = !DILocation(line: 51, column: 3, scope: !65)
!67 = distinct !{!67, !68}
!68 = !DILocation(line: 51, column: 3, scope: !37)
!69 = !DILocation(line: 44, column: 2, scope: !70)
!70 = !DILexicalBlockFile(scope: !38, file: !11, discriminator: 1)
!71 = distinct !{!71, !34}
!72 = !DILocation(line: 58, column: 1, scope: !10)
!73 = distinct !DISubprogram(name: "chatTX", scope: !11, file: !11, line: 66, type: !12, isLocal: false, isDefinition: true, scopeLine: 67, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!74 = !{!"chatTX"}
!75 = !DILocalVariable(name: "parameters", arg: 1, scope: !73, file: !11, line: 66, type: !4)
!76 = !DILocation(line: 66, column: 21, scope: !73)
!77 = !DILocalVariable(name: "i", scope: !73, file: !11, line: 68, type: !22)
!78 = !DILocation(line: 68, column: 6, scope: !73)
!79 = !DILocation(line: 71, column: 6, scope: !80)
!80 = distinct !DILexicalBlock(scope: !73, file: !11, line: 71, column: 6)
!81 = !DILocation(line: 71, column: 17, scope: !80)
!82 = !DILocation(line: 71, column: 6, scope: !73)
!83 = !DILocation(line: 73, column: 5, scope: !84)
!84 = distinct !DILexicalBlock(scope: !80, file: !11, line: 72, column: 2)
!85 = !DILocation(line: 74, column: 2, scope: !84)
!86 = !DILocation(line: 76, column: 2, scope: !73)
!87 = !DILocation(line: 76, column: 2, scope: !88)
!88 = !DILexicalBlockFile(scope: !89, file: !11, discriminator: 1)
!89 = distinct !DILexicalBlock(scope: !90, file: !11, line: 76, column: 2)
!90 = distinct !DILexicalBlock(scope: !73, file: !11, line: 76, column: 2)
!91 = distinct !{!91, !86}
!92 = !DILocation(line: 82, column: 1, scope: !73)
!93 = distinct !DISubprogram(name: "chatRX", scope: !11, file: !11, line: 84, type: !12, isLocal: false, isDefinition: true, scopeLine: 85, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!94 = !{!"chatRX"}
!95 = !DILocalVariable(name: "parameters", arg: 1, scope: !93, file: !11, line: 84, type: !4)
!96 = !DILocation(line: 84, column: 21, scope: !93)
!97 = !DILocalVariable(name: "i", scope: !93, file: !11, line: 86, type: !22)
!98 = !DILocation(line: 86, column: 6, scope: !93)
!99 = !DILocation(line: 89, column: 6, scope: !100)
!100 = distinct !DILexicalBlock(scope: !93, file: !11, line: 89, column: 6)
!101 = !DILocation(line: 89, column: 17, scope: !100)
!102 = !DILocation(line: 89, column: 6, scope: !93)
!103 = !DILocation(line: 91, column: 5, scope: !104)
!104 = distinct !DILexicalBlock(scope: !100, file: !11, line: 90, column: 2)
!105 = !DILocation(line: 92, column: 2, scope: !104)
!106 = !DILocation(line: 94, column: 2, scope: !93)
!107 = !DILocation(line: 94, column: 2, scope: !108)
!108 = !DILexicalBlockFile(scope: !109, file: !11, discriminator: 1)
!109 = distinct !DILexicalBlock(scope: !110, file: !11, line: 94, column: 2)
!110 = distinct !DILexicalBlock(scope: !93, file: !11, line: 94, column: 2)
!111 = distinct !{!111, !106}
!112 = !DILocation(line: 100, column: 1, scope: !93)
!113 = distinct !DISubprogram(name: "blinky", scope: !11, file: !11, line: 112, type: !12, isLocal: false, isDefinition: true, scopeLine: 113, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!114 = !{!"blinky"}
!115 = !DILocalVariable(name: "parameters", arg: 1, scope: !113, file: !11, line: 112, type: !4)
!116 = !DILocation(line: 112, column: 20, scope: !113)
!117 = !DILocalVariable(name: "i", scope: !113, file: !11, line: 114, type: !22)
!118 = !DILocation(line: 114, column: 6, scope: !113)
!119 = !DILocalVariable(name: "j", scope: !113, file: !11, line: 114, type: !22)
!120 = !DILocation(line: 114, column: 9, scope: !113)
!121 = !DILocalVariable(name: "hold", scope: !113, file: !11, line: 115, type: !122)
!122 = !DIDerivedType(tag: DW_TAG_volatile_type, baseType: !22)
!123 = !DILocation(line: 115, column: 15, scope: !113)
!124 = !DILocalVariable(name: "LED_Gpio", scope: !113, file: !11, line: 116, type: !125)
!125 = !DIDerivedType(tag: DW_TAG_typedef, name: "XGpio", file: !126, line: 162, baseType: !127)
!126 = !DIFile(filename: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp\5Cxgpio.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!127 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !126, line: 157, size: 128, align: 32, elements: !128)
!128 = !{!129, !137, !142, !143}
!129 = !DIDerivedType(tag: DW_TAG_member, name: "BaseAddress", scope: !127, file: !126, line: 158, baseType: !130, size: 32, align: 32)
!130 = !DIDerivedType(tag: DW_TAG_typedef, name: "UINTPTR", file: !131, line: 143, baseType: !132)
!131 = !DIFile(filename: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/xil_types.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!132 = !DIDerivedType(tag: DW_TAG_typedef, name: "uintptr_t", file: !133, line: 43, baseType: !134)
!133 = !DIFile(filename: "E:/SDSoC/SDK/2018.2/gnu/aarch32/nt/gcc-arm-none-eabi/arm-none-eabi/libc/usr/include\5Csys/_stdint.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!134 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uintptr_t", file: !135, line: 202, baseType: !136)
!135 = !DIFile(filename: "E:/SDSoC/SDK/2018.2/gnu/aarch32/nt/gcc-arm-none-eabi/arm-none-eabi/libc/usr/include\5Cmachine/_default_types.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!136 = !DIBasicType(name: "long unsigned int", size: 32, align: 32, encoding: DW_ATE_unsigned)
!137 = !DIDerivedType(tag: DW_TAG_member, name: "IsReady", scope: !127, file: !126, line: 159, baseType: !138, size: 32, align: 32, offset: 32)
!138 = !DIDerivedType(tag: DW_TAG_typedef, name: "u32", file: !131, line: 96, baseType: !139)
!139 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !133, line: 32, baseType: !140)
!140 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint32_t", file: !135, line: 65, baseType: !141)
!141 = !DIBasicType(name: "unsigned int", size: 32, align: 32, encoding: DW_ATE_unsigned)
!142 = !DIDerivedType(tag: DW_TAG_member, name: "InterruptPresent", scope: !127, file: !126, line: 160, baseType: !22, size: 32, align: 32, offset: 64)
!143 = !DIDerivedType(tag: DW_TAG_member, name: "IsDual", scope: !127, file: !126, line: 161, baseType: !22, size: 32, align: 32, offset: 96)
!144 = !DILocation(line: 116, column: 8, scope: !113)
!145 = !DILocalVariable(name: "Status", scope: !113, file: !11, line: 117, type: !22)
!146 = !DILocation(line: 117, column: 6, scope: !113)
!147 = !DILocation(line: 120, column: 6, scope: !148)
!148 = distinct !DILexicalBlock(scope: !113, file: !11, line: 120, column: 6)
!149 = !DILocation(line: 120, column: 17, scope: !148)
!150 = !DILocation(line: 120, column: 6, scope: !113)
!151 = !DILocation(line: 122, column: 5, scope: !152)
!152 = distinct !DILexicalBlock(scope: !148, file: !11, line: 121, column: 2)
!153 = !DILocation(line: 123, column: 2, scope: !152)
!154 = !DILocation(line: 125, column: 11, scope: !113)
!155 = !DILocation(line: 125, column: 9, scope: !113)
!156 = !DILocation(line: 126, column: 6, scope: !157)
!157 = distinct !DILexicalBlock(scope: !113, file: !11, line: 126, column: 6)
!158 = !DILocation(line: 126, column: 13, scope: !157)
!159 = !DILocation(line: 126, column: 6, scope: !113)
!160 = !DILocation(line: 128, column: 3, scope: !161)
!161 = distinct !DILexicalBlock(scope: !157, file: !11, line: 127, column: 2)
!162 = !DILocation(line: 129, column: 3, scope: !161)
!163 = !DILocation(line: 132, column: 2, scope: !113)
!164 = !DILocation(line: 134, column: 4, scope: !113)
!165 = !DILocation(line: 136, column: 2, scope: !113)
!166 = !DILocation(line: 138, column: 10, scope: !167)
!167 = distinct !DILexicalBlock(scope: !168, file: !11, line: 138, column: 3)
!168 = distinct !DILexicalBlock(scope: !169, file: !11, line: 137, column: 2)
!169 = distinct !DILexicalBlock(scope: !170, file: !11, line: 136, column: 2)
!170 = distinct !DILexicalBlock(scope: !113, file: !11, line: 136, column: 2)
!171 = !DILocation(line: 138, column: 8, scope: !167)
!172 = !DILocation(line: 138, column: 15, scope: !173)
!173 = !DILexicalBlockFile(scope: !174, file: !11, discriminator: 1)
!174 = distinct !DILexicalBlock(scope: !167, file: !11, line: 138, column: 3)
!175 = !DILocation(line: 138, column: 17, scope: !173)
!176 = !DILocation(line: 138, column: 3, scope: !173)
!177 = !DILocation(line: 140, column: 9, scope: !178)
!178 = distinct !DILexicalBlock(scope: !174, file: !11, line: 139, column: 3)
!179 = !DILocation(line: 141, column: 3, scope: !178)
!180 = !DILocation(line: 138, column: 31, scope: !181)
!181 = !DILexicalBlockFile(scope: !174, file: !11, discriminator: 2)
!182 = !DILocation(line: 138, column: 3, scope: !181)
!183 = distinct !{!183, !184}
!184 = !DILocation(line: 138, column: 3, scope: !168)
!185 = !DILocation(line: 145, column: 7, scope: !186)
!186 = distinct !DILexicalBlock(scope: !168, file: !11, line: 145, column: 7)
!187 = !DILocation(line: 145, column: 9, scope: !186)
!188 = !DILocation(line: 145, column: 7, scope: !168)
!189 = !DILocation(line: 147, column: 4, scope: !190)
!190 = distinct !DILexicalBlock(scope: !186, file: !11, line: 146, column: 3)
!191 = !DILocation(line: 148, column: 5, scope: !190)
!192 = !DILocation(line: 149, column: 3, scope: !190)
!193 = !DILocation(line: 152, column: 6, scope: !194)
!194 = distinct !DILexicalBlock(scope: !186, file: !11, line: 151, column: 3)
!195 = !DILocation(line: 153, column: 4, scope: !194)
!196 = !DILocation(line: 136, column: 2, scope: !197)
!197 = !DILexicalBlockFile(scope: !169, file: !11, discriminator: 1)
!198 = distinct !{!198, !165}
!199 = !{!"XGpio_Initialize"}
!200 = !{!"int.XGpio *.1.u16.0"}
!201 = !{!"C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp\5Cxgpio.h"}
!202 = !{!"xil_printf"}
!203 = !{!"void.const char8 *.1"}
!204 = !{!"C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/xil_printf.h"}
!205 = !{!"XGpio_SetDataDirection"}
!206 = !{!"void.XGpio *.1.unsigned int.0.u32.0"}
!207 = !{!"XGpio_DiscreteWrite"}
!208 = !{!"XGpio_DiscreteClear"}
