; ModuleID = 'C:/Users/TimothyDuke/workspace/ArtyFreeTest/src/talky.c'
source_filename = "C:/Users/TimothyDuke/workspace/ArtyFreeTest/src/talky.c"
target datalayout = "e-m:e-p:32:32-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "armv7-none--eabi"

%struct.XGpio = type { i32, i32, i32, i32 }

@.str = private unnamed_addr constant [17 x i8] c"Loop number: %i\0A\00", align 1
@.str.1 = private unnamed_addr constant [19 x i8] c"I'm also printing\0A\00", align 1
@.str.2 = private unnamed_addr constant [17 x i8] c"GPIO Init Error\0A\00", align 1
@.str.3 = private unnamed_addr constant [5 x i8] c"LED\0A\00", align 1

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
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str, i32 0, i32 0), i32* %4), !dbg !47
  br label %15, !dbg !49

; <label>:15:                                     ; preds = %14
  %16 = load i32, i32* %4, align 4, !dbg !50
  %17 = add nsw i32 %16, 1, !dbg !50
  store i32 %17, i32* %4, align 4, !dbg !50
  br label %10, !dbg !52, !llvm.loop !53

; <label>:18:                                     ; preds = %10
  store i32 0, i32* %4, align 4, !dbg !55
  br label %19, !dbg !57

; <label>:19:                                     ; preds = %23, %18
  %20 = load i32, i32* %4, align 4, !dbg !58
  %21 = icmp slt i32 %20, 10000, !dbg !61
  br i1 %21, label %22, label %26, !dbg !62

; <label>:22:                                     ; preds = %19
  br label %23, !dbg !63

; <label>:23:                                     ; preds = %22
  %24 = load i32, i32* %4, align 4, !dbg !65
  %25 = add nsw i32 %24, 1, !dbg !65
  store i32 %25, i32* %4, align 4, !dbg !65
  br label %19, !dbg !67, !llvm.loop !68

; <label>:26:                                     ; preds = %19
  br label %9, !dbg !70, !llvm.loop !72
                                                  ; No predecessors!
  ret void, !dbg !73
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

declare !xidane.fname !74 !xidane.function_declaration_type !75 !xidane.function_declaration_filename !76 !xidane.ExternC !17 void @xil_printf(i8*, ...) #2

; Function Attrs: nounwind
define void @chatTX(i8*) #0 !dbg !77 !xidane.fname !78 !xidane.function_declaration_type !15 !xidane.function_declaration_filename !16 !xidane.ExternC !17 {
  %2 = alloca i8*, align 4
  %3 = alloca i32, align 4
  store i8* %0, i8** %2, align 4
  call void @llvm.dbg.declare(metadata i8** %2, metadata !79, metadata !19), !dbg !80
  call void @llvm.dbg.declare(metadata i32* %3, metadata !81, metadata !19), !dbg !82
  %4 = load i8*, i8** %2, align 4, !dbg !83
  %5 = icmp eq i8* %4, null, !dbg !85
  br i1 %5, label %6, label %7, !dbg !86

; <label>:6:                                      ; preds = %1
  store i32 0, i32* %3, align 4, !dbg !87
  br label %7, !dbg !89

; <label>:7:                                      ; preds = %6, %1
  br label %8, !dbg !90

; <label>:8:                                      ; preds = %8, %7
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([19 x i8], [19 x i8]* @.str.1, i32 0, i32 0)), !dbg !91
  br label %8, !dbg !95, !llvm.loop !97
                                                  ; No predecessors!
  ret void, !dbg !98
}

; Function Attrs: nounwind
define void @chatRX(i8*) #0 !dbg !99 !xidane.fname !100 !xidane.function_declaration_type !15 !xidane.function_declaration_filename !16 !xidane.ExternC !17 {
  %2 = alloca i8*, align 4
  %3 = alloca i32, align 4
  store i8* %0, i8** %2, align 4
  call void @llvm.dbg.declare(metadata i8** %2, metadata !101, metadata !19), !dbg !102
  call void @llvm.dbg.declare(metadata i32* %3, metadata !103, metadata !19), !dbg !104
  %4 = load i8*, i8** %2, align 4, !dbg !105
  %5 = icmp eq i8* %4, null, !dbg !107
  br i1 %5, label %6, label %7, !dbg !108

; <label>:6:                                      ; preds = %1
  store i32 0, i32* %3, align 4, !dbg !109
  br label %7, !dbg !111

; <label>:7:                                      ; preds = %6, %1
  br label %8, !dbg !112

; <label>:8:                                      ; preds = %8, %7
  br label %8, !dbg !113, !llvm.loop !117
                                                  ; No predecessors!
  ret void, !dbg !118
}

; Function Attrs: nounwind
define void @blinky(i8*) #0 !dbg !119 !xidane.fname !120 !xidane.function_declaration_type !15 !xidane.function_declaration_filename !16 !xidane.ExternC !17 {
  %2 = alloca i8*, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca %struct.XGpio, align 4
  %7 = alloca i32, align 4
  store i8* %0, i8** %2, align 4
  call void @llvm.dbg.declare(metadata i8** %2, metadata !121, metadata !19), !dbg !122
  call void @llvm.dbg.declare(metadata i32* %3, metadata !123, metadata !19), !dbg !124
  call void @llvm.dbg.declare(metadata i32* %4, metadata !125, metadata !19), !dbg !126
  call void @llvm.dbg.declare(metadata i32* %5, metadata !127, metadata !19), !dbg !129
  call void @llvm.dbg.declare(metadata %struct.XGpio* %6, metadata !130, metadata !19), !dbg !150
  call void @llvm.dbg.declare(metadata i32* %7, metadata !151, metadata !19), !dbg !152
  %8 = load i8*, i8** %2, align 4, !dbg !153
  %9 = icmp eq i8* %8, null, !dbg !155
  br i1 %9, label %10, label %11, !dbg !156

; <label>:10:                                     ; preds = %1
  store i32 0, i32* %3, align 4, !dbg !157
  br label %11, !dbg !159

; <label>:11:                                     ; preds = %10, %1
  %12 = call i32 @XGpio_Initialize(%struct.XGpio* %6, i16 zeroext 1), !dbg !160
  store i32 %12, i32* %7, align 4, !dbg !161
  %13 = load i32, i32* %7, align 4, !dbg !162
  %14 = icmp ne i32 %13, 0, !dbg !164
  br i1 %14, label %15, label %16, !dbg !165

; <label>:15:                                     ; preds = %11
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str.2, i32 0, i32 0)), !dbg !166
  ret void, !dbg !168

; <label>:16:                                     ; preds = %11
  call void @XGpio_SetDataDirection(%struct.XGpio* %6, i32 1, i32 -256), !dbg !169
  store i32 0, i32* %4, align 4, !dbg !170
  br label %17, !dbg !171

; <label>:17:                                     ; preds = %32, %16
  store i32 0, i32* %3, align 4, !dbg !172
  br label %18, !dbg !177

; <label>:18:                                     ; preds = %22, %17
  %19 = load i32, i32* %3, align 4, !dbg !178
  %20 = icmp slt i32 %19, 100000, !dbg !181
  br i1 %20, label %21, label %25, !dbg !182

; <label>:21:                                     ; preds = %18
  store volatile i32 0, i32* %5, align 4, !dbg !183
  br label %22, !dbg !185

; <label>:22:                                     ; preds = %21
  %23 = load i32, i32* %3, align 4, !dbg !186
  %24 = add nsw i32 %23, 1, !dbg !186
  store i32 %24, i32* %3, align 4, !dbg !186
  br label %18, !dbg !188, !llvm.loop !189

; <label>:25:                                     ; preds = %18
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.3, i32 0, i32 0)), !dbg !191
  %26 = load i32, i32* %4, align 4, !dbg !192
  %27 = icmp eq i32 %26, 0, !dbg !194
  br i1 %27, label %28, label %31, !dbg !195

; <label>:28:                                     ; preds = %25
  call void @XGpio_DiscreteWrite(%struct.XGpio* %6, i32 1, i32 255), !dbg !196
  %29 = load i32, i32* %4, align 4, !dbg !198
  %30 = add nsw i32 %29, 1, !dbg !198
  store i32 %30, i32* %4, align 4, !dbg !198
  br label %32, !dbg !199

; <label>:31:                                     ; preds = %25
  store i32 0, i32* %4, align 4, !dbg !200
  call void @XGpio_DiscreteClear(%struct.XGpio* %6, i32 1, i32 255), !dbg !202
  br label %32

; <label>:32:                                     ; preds = %31, %28
  br label %17, !dbg !203, !llvm.loop !205
}

declare !xidane.fname !206 !xidane.function_declaration_type !207 !xidane.function_declaration_filename !208 !xidane.ExternC !17 i32 @XGpio_Initialize(%struct.XGpio*, i16 zeroext) #2

declare !xidane.fname !209 !xidane.function_declaration_type !210 !xidane.function_declaration_filename !208 !xidane.ExternC !17 void @XGpio_SetDataDirection(%struct.XGpio*, i32, i32) #2

declare !xidane.fname !211 !xidane.function_declaration_type !210 !xidane.function_declaration_filename !208 !xidane.ExternC !17 void @XGpio_DiscreteWrite(%struct.XGpio*, i32, i32) #2

declare !xidane.fname !212 !xidane.function_declaration_type !210 !xidane.function_declaration_filename !208 !xidane.ExternC !17 void @XGpio_DiscreteClear(%struct.XGpio*, i32, i32) #2

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
!47 = !DILocation(line: 48, column: 4, scope: !48)
!48 = distinct !DILexicalBlock(scope: !43, file: !11, line: 47, column: 3)
!49 = !DILocation(line: 49, column: 3, scope: !48)
!50 = !DILocation(line: 46, column: 27, scope: !51)
!51 = !DILexicalBlockFile(scope: !43, file: !11, discriminator: 2)
!52 = !DILocation(line: 46, column: 3, scope: !51)
!53 = distinct !{!53, !54}
!54 = !DILocation(line: 46, column: 3, scope: !37)
!55 = !DILocation(line: 51, column: 10, scope: !56)
!56 = distinct !DILexicalBlock(scope: !37, file: !11, line: 51, column: 3)
!57 = !DILocation(line: 51, column: 8, scope: !56)
!58 = !DILocation(line: 51, column: 15, scope: !59)
!59 = !DILexicalBlockFile(scope: !60, file: !11, discriminator: 1)
!60 = distinct !DILexicalBlock(scope: !56, file: !11, line: 51, column: 3)
!61 = !DILocation(line: 51, column: 17, scope: !59)
!62 = !DILocation(line: 51, column: 3, scope: !59)
!63 = !DILocation(line: 54, column: 3, scope: !64)
!64 = distinct !DILexicalBlock(scope: !60, file: !11, line: 52, column: 3)
!65 = !DILocation(line: 51, column: 27, scope: !66)
!66 = !DILexicalBlockFile(scope: !60, file: !11, discriminator: 2)
!67 = !DILocation(line: 51, column: 3, scope: !66)
!68 = distinct !{!68, !69}
!69 = !DILocation(line: 51, column: 3, scope: !37)
!70 = !DILocation(line: 44, column: 2, scope: !71)
!71 = !DILexicalBlockFile(scope: !38, file: !11, discriminator: 1)
!72 = distinct !{!72, !34}
!73 = !DILocation(line: 58, column: 1, scope: !10)
!74 = !{!"xil_printf"}
!75 = !{!"void.const char8 *.1"}
!76 = !{!"C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/xil_printf.h"}
!77 = distinct !DISubprogram(name: "chatTX", scope: !11, file: !11, line: 66, type: !12, isLocal: false, isDefinition: true, scopeLine: 67, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!78 = !{!"chatTX"}
!79 = !DILocalVariable(name: "parameters", arg: 1, scope: !77, file: !11, line: 66, type: !4)
!80 = !DILocation(line: 66, column: 21, scope: !77)
!81 = !DILocalVariable(name: "i", scope: !77, file: !11, line: 68, type: !22)
!82 = !DILocation(line: 68, column: 6, scope: !77)
!83 = !DILocation(line: 71, column: 6, scope: !84)
!84 = distinct !DILexicalBlock(scope: !77, file: !11, line: 71, column: 6)
!85 = !DILocation(line: 71, column: 17, scope: !84)
!86 = !DILocation(line: 71, column: 6, scope: !77)
!87 = !DILocation(line: 73, column: 5, scope: !88)
!88 = distinct !DILexicalBlock(scope: !84, file: !11, line: 72, column: 2)
!89 = !DILocation(line: 74, column: 2, scope: !88)
!90 = !DILocation(line: 76, column: 2, scope: !77)
!91 = !DILocation(line: 78, column: 3, scope: !92)
!92 = distinct !DILexicalBlock(scope: !93, file: !11, line: 77, column: 2)
!93 = distinct !DILexicalBlock(scope: !94, file: !11, line: 76, column: 2)
!94 = distinct !DILexicalBlock(scope: !77, file: !11, line: 76, column: 2)
!95 = !DILocation(line: 76, column: 2, scope: !96)
!96 = !DILexicalBlockFile(scope: !93, file: !11, discriminator: 1)
!97 = distinct !{!97, !90}
!98 = !DILocation(line: 82, column: 1, scope: !77)
!99 = distinct !DISubprogram(name: "chatRX", scope: !11, file: !11, line: 84, type: !12, isLocal: false, isDefinition: true, scopeLine: 85, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!100 = !{!"chatRX"}
!101 = !DILocalVariable(name: "parameters", arg: 1, scope: !99, file: !11, line: 84, type: !4)
!102 = !DILocation(line: 84, column: 21, scope: !99)
!103 = !DILocalVariable(name: "i", scope: !99, file: !11, line: 86, type: !22)
!104 = !DILocation(line: 86, column: 6, scope: !99)
!105 = !DILocation(line: 89, column: 6, scope: !106)
!106 = distinct !DILexicalBlock(scope: !99, file: !11, line: 89, column: 6)
!107 = !DILocation(line: 89, column: 17, scope: !106)
!108 = !DILocation(line: 89, column: 6, scope: !99)
!109 = !DILocation(line: 91, column: 5, scope: !110)
!110 = distinct !DILexicalBlock(scope: !106, file: !11, line: 90, column: 2)
!111 = !DILocation(line: 92, column: 2, scope: !110)
!112 = !DILocation(line: 94, column: 2, scope: !99)
!113 = !DILocation(line: 94, column: 2, scope: !114)
!114 = !DILexicalBlockFile(scope: !115, file: !11, discriminator: 1)
!115 = distinct !DILexicalBlock(scope: !116, file: !11, line: 94, column: 2)
!116 = distinct !DILexicalBlock(scope: !99, file: !11, line: 94, column: 2)
!117 = distinct !{!117, !112}
!118 = !DILocation(line: 100, column: 1, scope: !99)
!119 = distinct !DISubprogram(name: "blinky", scope: !11, file: !11, line: 112, type: !12, isLocal: false, isDefinition: true, scopeLine: 113, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!120 = !{!"blinky"}
!121 = !DILocalVariable(name: "parameters", arg: 1, scope: !119, file: !11, line: 112, type: !4)
!122 = !DILocation(line: 112, column: 20, scope: !119)
!123 = !DILocalVariable(name: "i", scope: !119, file: !11, line: 114, type: !22)
!124 = !DILocation(line: 114, column: 6, scope: !119)
!125 = !DILocalVariable(name: "j", scope: !119, file: !11, line: 114, type: !22)
!126 = !DILocation(line: 114, column: 9, scope: !119)
!127 = !DILocalVariable(name: "hold", scope: !119, file: !11, line: 115, type: !128)
!128 = !DIDerivedType(tag: DW_TAG_volatile_type, baseType: !22)
!129 = !DILocation(line: 115, column: 15, scope: !119)
!130 = !DILocalVariable(name: "LED_Gpio", scope: !119, file: !11, line: 116, type: !131)
!131 = !DIDerivedType(tag: DW_TAG_typedef, name: "XGpio", file: !132, line: 162, baseType: !133)
!132 = !DIFile(filename: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp\5Cxgpio.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!133 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !132, line: 157, size: 128, align: 32, elements: !134)
!134 = !{!135, !143, !148, !149}
!135 = !DIDerivedType(tag: DW_TAG_member, name: "BaseAddress", scope: !133, file: !132, line: 158, baseType: !136, size: 32, align: 32)
!136 = !DIDerivedType(tag: DW_TAG_typedef, name: "UINTPTR", file: !137, line: 143, baseType: !138)
!137 = !DIFile(filename: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/xil_types.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!138 = !DIDerivedType(tag: DW_TAG_typedef, name: "uintptr_t", file: !139, line: 43, baseType: !140)
!139 = !DIFile(filename: "E:/SDSoC/SDK/2018.2/gnu/aarch32/nt/gcc-arm-none-eabi/arm-none-eabi/libc/usr/include\5Csys/_stdint.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!140 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uintptr_t", file: !141, line: 202, baseType: !142)
!141 = !DIFile(filename: "E:/SDSoC/SDK/2018.2/gnu/aarch32/nt/gcc-arm-none-eabi/arm-none-eabi/libc/usr/include\5Cmachine/_default_types.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!142 = !DIBasicType(name: "long unsigned int", size: 32, align: 32, encoding: DW_ATE_unsigned)
!143 = !DIDerivedType(tag: DW_TAG_member, name: "IsReady", scope: !133, file: !132, line: 159, baseType: !144, size: 32, align: 32, offset: 32)
!144 = !DIDerivedType(tag: DW_TAG_typedef, name: "u32", file: !137, line: 96, baseType: !145)
!145 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !139, line: 32, baseType: !146)
!146 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint32_t", file: !141, line: 65, baseType: !147)
!147 = !DIBasicType(name: "unsigned int", size: 32, align: 32, encoding: DW_ATE_unsigned)
!148 = !DIDerivedType(tag: DW_TAG_member, name: "InterruptPresent", scope: !133, file: !132, line: 160, baseType: !22, size: 32, align: 32, offset: 64)
!149 = !DIDerivedType(tag: DW_TAG_member, name: "IsDual", scope: !133, file: !132, line: 161, baseType: !22, size: 32, align: 32, offset: 96)
!150 = !DILocation(line: 116, column: 8, scope: !119)
!151 = !DILocalVariable(name: "Status", scope: !119, file: !11, line: 117, type: !22)
!152 = !DILocation(line: 117, column: 6, scope: !119)
!153 = !DILocation(line: 120, column: 6, scope: !154)
!154 = distinct !DILexicalBlock(scope: !119, file: !11, line: 120, column: 6)
!155 = !DILocation(line: 120, column: 17, scope: !154)
!156 = !DILocation(line: 120, column: 6, scope: !119)
!157 = !DILocation(line: 122, column: 5, scope: !158)
!158 = distinct !DILexicalBlock(scope: !154, file: !11, line: 121, column: 2)
!159 = !DILocation(line: 123, column: 2, scope: !158)
!160 = !DILocation(line: 125, column: 11, scope: !119)
!161 = !DILocation(line: 125, column: 9, scope: !119)
!162 = !DILocation(line: 126, column: 6, scope: !163)
!163 = distinct !DILexicalBlock(scope: !119, file: !11, line: 126, column: 6)
!164 = !DILocation(line: 126, column: 13, scope: !163)
!165 = !DILocation(line: 126, column: 6, scope: !119)
!166 = !DILocation(line: 128, column: 3, scope: !167)
!167 = distinct !DILexicalBlock(scope: !163, file: !11, line: 127, column: 2)
!168 = !DILocation(line: 129, column: 3, scope: !167)
!169 = !DILocation(line: 132, column: 2, scope: !119)
!170 = !DILocation(line: 134, column: 4, scope: !119)
!171 = !DILocation(line: 136, column: 2, scope: !119)
!172 = !DILocation(line: 138, column: 10, scope: !173)
!173 = distinct !DILexicalBlock(scope: !174, file: !11, line: 138, column: 3)
!174 = distinct !DILexicalBlock(scope: !175, file: !11, line: 137, column: 2)
!175 = distinct !DILexicalBlock(scope: !176, file: !11, line: 136, column: 2)
!176 = distinct !DILexicalBlock(scope: !119, file: !11, line: 136, column: 2)
!177 = !DILocation(line: 138, column: 8, scope: !173)
!178 = !DILocation(line: 138, column: 15, scope: !179)
!179 = !DILexicalBlockFile(scope: !180, file: !11, discriminator: 1)
!180 = distinct !DILexicalBlock(scope: !173, file: !11, line: 138, column: 3)
!181 = !DILocation(line: 138, column: 17, scope: !179)
!182 = !DILocation(line: 138, column: 3, scope: !179)
!183 = !DILocation(line: 140, column: 9, scope: !184)
!184 = distinct !DILexicalBlock(scope: !180, file: !11, line: 139, column: 3)
!185 = !DILocation(line: 141, column: 3, scope: !184)
!186 = !DILocation(line: 138, column: 31, scope: !187)
!187 = !DILexicalBlockFile(scope: !180, file: !11, discriminator: 2)
!188 = !DILocation(line: 138, column: 3, scope: !187)
!189 = distinct !{!189, !190}
!190 = !DILocation(line: 138, column: 3, scope: !174)
!191 = !DILocation(line: 143, column: 3, scope: !174)
!192 = !DILocation(line: 145, column: 7, scope: !193)
!193 = distinct !DILexicalBlock(scope: !174, file: !11, line: 145, column: 7)
!194 = !DILocation(line: 145, column: 9, scope: !193)
!195 = !DILocation(line: 145, column: 7, scope: !174)
!196 = !DILocation(line: 147, column: 4, scope: !197)
!197 = distinct !DILexicalBlock(scope: !193, file: !11, line: 146, column: 3)
!198 = !DILocation(line: 148, column: 5, scope: !197)
!199 = !DILocation(line: 149, column: 3, scope: !197)
!200 = !DILocation(line: 152, column: 6, scope: !201)
!201 = distinct !DILexicalBlock(scope: !193, file: !11, line: 151, column: 3)
!202 = !DILocation(line: 153, column: 4, scope: !201)
!203 = !DILocation(line: 136, column: 2, scope: !204)
!204 = !DILexicalBlockFile(scope: !175, file: !11, discriminator: 1)
!205 = distinct !{!205, !171}
!206 = !{!"XGpio_Initialize"}
!207 = !{!"int.XGpio *.1.u16.0"}
!208 = !{!"C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp\5Cxgpio.h"}
!209 = !{!"XGpio_SetDataDirection"}
!210 = !{!"void.XGpio *.1.unsigned int.0.u32.0"}
!211 = !{!"XGpio_DiscreteWrite"}
!212 = !{!"XGpio_DiscreteClear"}
