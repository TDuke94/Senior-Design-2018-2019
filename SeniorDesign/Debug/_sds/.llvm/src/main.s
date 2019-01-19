; ModuleID = '/home/timothyduke/workspace/SeniorDesign/src/main.c'
source_filename = "/home/timothyduke/workspace/SeniorDesign/src/main.c"
target datalayout = "e-m:e-p:32:32-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "armv7-none--eabi"

@.str = private unnamed_addr constant [28 x i8] c"counting inside of main :)\0A\00", align 1

; Function Attrs: nounwind
define i32 @main() #0 !dbg !8 !xidane.fname !13 !xidane.function_declaration_type !14 !xidane.function_declaration_filename !15 !xidane.ExternC !16 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  call void @llvm.dbg.declare(metadata i32* %2, metadata !17, metadata !18), !dbg !19
  call void @dispatchPipeline(), !dbg !20
  store i32 0, i32* %2, align 4, !dbg !21
  br label %3, !dbg !23

; <label>:3:                                      ; preds = %7, %0
  %4 = load i32, i32* %2, align 4, !dbg !24
  %5 = icmp slt i32 %4, 10, !dbg !27
  br i1 %5, label %6, label %10, !dbg !28

; <label>:6:                                      ; preds = %3
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str, i32 0, i32 0)), !dbg !29
  br label %7, !dbg !31

; <label>:7:                                      ; preds = %6
  %8 = load i32, i32* %2, align 4, !dbg !32
  %9 = add nsw i32 %8, 1, !dbg !32
  store i32 %9, i32* %2, align 4, !dbg !32
  br label %3, !dbg !34, !llvm.loop !35

; <label>:10:                                     ; preds = %3
  br label %11, !dbg !37

; <label>:11:                                     ; preds = %11, %10
  br label %11, !dbg !38, !llvm.loop !42
                                                  ; No predecessors!
  %13 = load i32, i32* %1, align 4, !dbg !43
  ret i32 %13, !dbg !43
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

declare !xidane.fname !44 !xidane.function_declaration_type !45 !xidane.function_declaration_filename !46 !xidane.ExternC !16 void @dispatchPipeline() #2

declare !xidane.fname !47 !xidane.function_declaration_type !48 !xidane.function_declaration_filename !49 !xidane.ExternC !16 void @xil_printf(i8*, ...) #2

attributes #0 = { nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-a9" "target-features"="+dsp,+strict-align,+vfp3,-crypto,-d16,-fp-armv8,-fp-only-sp,-fp16,-neon,-vfp4" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-a9" "target-features"="+dsp,+strict-align,+vfp3,-crypto,-d16,-fp-armv8,-fp-only-sp,-fp16,-neon,-vfp4" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5, !6}
!llvm.ident = !{!7}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 3.9.0 (tags/RELEASE_390/final)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2)
!1 = !DIFile(filename: "../src/main.c", directory: "/home/timothyduke/workspace/SeniorDesign/Debug")
!2 = !{}
!3 = !{i32 2, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 4}
!6 = !{i32 1, !"min_enum_size", i32 4}
!7 = !{!"clang version 3.9.0 (tags/RELEASE_390/final)"}
!8 = distinct !DISubprogram(name: "main", scope: !9, file: !9, line: 36, type: !10, isLocal: false, isDefinition: true, scopeLine: 37, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!9 = !DIFile(filename: "/home/timothyduke/workspace/SeniorDesign/src/main.c", directory: "/home/timothyduke/workspace/SeniorDesign/Debug")
!10 = !DISubroutineType(types: !11)
!11 = !{!12}
!12 = !DIBasicType(name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!13 = !{!"main"}
!14 = !{!"int."}
!15 = !{!"/home/timothyduke/workspace/SeniorDesign/src/main.c"}
!16 = !{!"t"}
!17 = !DILocalVariable(name: "i", scope: !8, file: !9, line: 38, type: !12)
!18 = !DIExpression()
!19 = !DILocation(line: 38, column: 6, scope: !8)
!20 = !DILocation(line: 40, column: 2, scope: !8)
!21 = !DILocation(line: 42, column: 9, scope: !22)
!22 = distinct !DILexicalBlock(scope: !8, file: !9, line: 42, column: 2)
!23 = !DILocation(line: 42, column: 7, scope: !22)
!24 = !DILocation(line: 42, column: 14, scope: !25)
!25 = !DILexicalBlockFile(scope: !26, file: !9, discriminator: 1)
!26 = distinct !DILexicalBlock(scope: !22, file: !9, line: 42, column: 2)
!27 = !DILocation(line: 42, column: 16, scope: !25)
!28 = !DILocation(line: 42, column: 2, scope: !25)
!29 = !DILocation(line: 44, column: 3, scope: !30)
!30 = distinct !DILexicalBlock(scope: !26, file: !9, line: 43, column: 2)
!31 = !DILocation(line: 45, column: 2, scope: !30)
!32 = !DILocation(line: 42, column: 23, scope: !33)
!33 = !DILexicalBlockFile(scope: !26, file: !9, discriminator: 2)
!34 = !DILocation(line: 42, column: 2, scope: !33)
!35 = distinct !{!35, !36}
!36 = !DILocation(line: 42, column: 2, scope: !8)
!37 = !DILocation(line: 47, column: 2, scope: !8)
!38 = !DILocation(line: 47, column: 2, scope: !39)
!39 = !DILexicalBlockFile(scope: !40, file: !9, discriminator: 1)
!40 = distinct !DILexicalBlock(scope: !41, file: !9, line: 47, column: 2)
!41 = distinct !DILexicalBlock(scope: !8, file: !9, line: 47, column: 2)
!42 = distinct !{!42, !37}
!43 = !DILocation(line: 54, column: 1, scope: !8)
!44 = !{!"dispatchPipeline"}
!45 = !{!"void."}
!46 = !{!"../src/dispatch.h"}
!47 = !{!"xil_printf"}
!48 = !{!"void.const char8 *.1"}
!49 = !{!"/home/timothyduke/workspace/Arty_Z7_20/export/Arty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/xil_printf.h"}
