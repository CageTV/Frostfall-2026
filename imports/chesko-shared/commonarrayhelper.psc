; COMPILE-TIME IMPORT ONLY (never shipped). Decompiled from the shipped script; defaults restored from source/evidence.
ScriptName CommonArrayHelper hidden
{ Global array helper functions. }

;-- Functions ---------------------------------------

; Skipped compiler generated GetState

; Skipped compiler generated GotoState

Event onBeginState()
{ Event received when this state is switched to }
  ; Empty function
EndEvent

Event onEndState()
{ Event received when this state is switched away from }
  ; Empty function
EndEvent

Int Function GetVersion() Global
  Return 2 ; #DEBUG_LINE_NO:5
EndFunction

Bool Function ArrayAddForm(Form[] akArray, Form akValue) Global
  Int i = 0 ; #DEBUG_LINE_NO:13
  While i < akArray.Length ; #DEBUG_LINE_NO:14
    If CommonArrayHelper.IsNone(akArray[i]) ; #DEBUG_LINE_NO:15
      akArray[i] = akValue ; #DEBUG_LINE_NO:16
      Return True ; #DEBUG_LINE_NO:17
    Else
      i += 1 ; #DEBUG_LINE_NO:19
    EndIf
  EndWhile
  Return False ; #DEBUG_LINE_NO:22
EndFunction

Bool Function ArrayAddAlias(Alias[] akArray, Alias akValue) Global
  Int i = 0 ; #DEBUG_LINE_NO:30
  While i < akArray.Length ; #DEBUG_LINE_NO:31
    If akArray[i] == None ; #DEBUG_LINE_NO:32
      akArray[i] = akValue ; #DEBUG_LINE_NO:33
      Return True ; #DEBUG_LINE_NO:34
    Else
      i += 1 ; #DEBUG_LINE_NO:36
    EndIf
  EndWhile
  Return False ; #DEBUG_LINE_NO:39
EndFunction

Bool Function ArrayAddActiveMagicEffect(ActiveMagicEffect[] akArray, ActiveMagicEffect akValue) Global
  Int i = 0 ; #DEBUG_LINE_NO:47
  While i < akArray.Length ; #DEBUG_LINE_NO:48
    If akArray[i] == None ; #DEBUG_LINE_NO:49
      akArray[i] = akValue ; #DEBUG_LINE_NO:50
      Return True ; #DEBUG_LINE_NO:51
    Else
      i += 1 ; #DEBUG_LINE_NO:53
    EndIf
  EndWhile
  Return False ; #DEBUG_LINE_NO:56
EndFunction

Bool Function ArrayAddArmor(Armor[] akArray, Armor akValue) Global
  Int i = 0 ; #DEBUG_LINE_NO:64
  While i < akArray.Length ; #DEBUG_LINE_NO:65
    If CommonArrayHelper.IsNone(akArray[i] as Form) ; #DEBUG_LINE_NO:66
      akArray[i] = akValue ; #DEBUG_LINE_NO:67
      Return True ; #DEBUG_LINE_NO:68
    Else
      i += 1 ; #DEBUG_LINE_NO:70
    EndIf
  EndWhile
  Return False ; #DEBUG_LINE_NO:73
EndFunction

Bool Function ArrayAddActivator(Activator[] akArray, Activator akValue) Global
  Int i = 0 ; #DEBUG_LINE_NO:81
  While i < akArray.Length ; #DEBUG_LINE_NO:82
    If CommonArrayHelper.IsNone(akArray[i] as Form) ; #DEBUG_LINE_NO:83
      akArray[i] = akValue ; #DEBUG_LINE_NO:84
      Return True ; #DEBUG_LINE_NO:85
    Else
      i += 1 ; #DEBUG_LINE_NO:87
    EndIf
  EndWhile
  Return False ; #DEBUG_LINE_NO:90
EndFunction

Bool Function ArrayAddRef(ObjectReference[] akArray, ObjectReference akValue) Global
  Int index = akArray.find(None, 0) ; #DEBUG_LINE_NO:94
  If index >= 0 ; #DEBUG_LINE_NO:95
    akArray[index] = akValue ; #DEBUG_LINE_NO:96
    Return True ; #DEBUG_LINE_NO:97
  Else
    Return False ; #DEBUG_LINE_NO:99
  EndIf
EndFunction

Bool Function ArrayAddBool(Bool[] abArray, Bool abValue, int aiIndex) Global
  If aiIndex < abArray.Length ; #DEBUG_LINE_NO:108
    abArray[aiIndex] = abValue ; #DEBUG_LINE_NO:109
    Return True ; #DEBUG_LINE_NO:110
  Else
    Return False ; #DEBUG_LINE_NO:112
  EndIf
EndFunction

Bool Function ArrayAddInt(int[] aiArray, int aiValue, int aiInsertAtValue = 0) Global
  Int i = 0 ; #DEBUG_LINE_NO:121
  While i < aiArray.Length ; #DEBUG_LINE_NO:122
    If aiArray[i] == aiInsertAtValue ; #DEBUG_LINE_NO:123
      aiArray[i] = aiValue ; #DEBUG_LINE_NO:124
      Return True ; #DEBUG_LINE_NO:125
    Else
      i += 1 ; #DEBUG_LINE_NO:127
    EndIf
  EndWhile
  Return False ; #DEBUG_LINE_NO:130
EndFunction

Bool Function ArrayAddFloat(float[] afArray, float afValue, float afInsertAtValue = 0.0) Global
  Int i = 0 ; #DEBUG_LINE_NO:138
  While i < afArray.Length ; #DEBUG_LINE_NO:139
    If afArray[i] == afInsertAtValue ; #DEBUG_LINE_NO:140
      afArray[i] = afValue ; #DEBUG_LINE_NO:141
      Return True ; #DEBUG_LINE_NO:142
    Else
      i += 1 ; #DEBUG_LINE_NO:144
    EndIf
  EndWhile
  Return False ; #DEBUG_LINE_NO:147
EndFunction

Bool Function ArrayAddString(String[] asArray, String asValue) Global
  Int i = 0 ; #DEBUG_LINE_NO:155
  While i < asArray.Length ; #DEBUG_LINE_NO:156
    If asArray[i] != "" ; #DEBUG_LINE_NO:157
      asArray[i] = asValue ; #DEBUG_LINE_NO:158
      Return True ; #DEBUG_LINE_NO:159
    Else
      i += 1 ; #DEBUG_LINE_NO:161
    EndIf
  EndWhile
  Return False ; #DEBUG_LINE_NO:164
EndFunction

Bool Function ArrayRemoveForm(Form[] akArray, Form akValue, bool abSort = false) Global
  Int i = 0 ; #DEBUG_LINE_NO:172
  While i < akArray.Length ; #DEBUG_LINE_NO:173
    If akArray[i] == akValue ; #DEBUG_LINE_NO:174
      akArray[i] = None ; #DEBUG_LINE_NO:175
      If abSort == True ; #DEBUG_LINE_NO:176
        CommonArrayHelper.ArraySortForm(akArray, 0) ; #DEBUG_LINE_NO:177
      EndIf
      Return True ; #DEBUG_LINE_NO:179
    Else
      i += 1 ; #DEBUG_LINE_NO:181
    EndIf
  EndWhile
  Return False ; #DEBUG_LINE_NO:185
EndFunction

Bool Function ArrayRemoveAlias(Alias[] akArray, Alias akValue, bool abSort = false) Global
  Int i = 0 ; #DEBUG_LINE_NO:194
  While i < akArray.Length ; #DEBUG_LINE_NO:195
    If akArray[i] == akValue ; #DEBUG_LINE_NO:196
      akArray[i] = None ; #DEBUG_LINE_NO:197
      If abSort == True ; #DEBUG_LINE_NO:198
        CommonArrayHelper.ArraySortAlias(akArray, 0) ; #DEBUG_LINE_NO:199
      EndIf
      Return True ; #DEBUG_LINE_NO:201
    Else
      i += 1 ; #DEBUG_LINE_NO:203
    EndIf
  EndWhile
  Return False ; #DEBUG_LINE_NO:207
EndFunction

Bool Function ArrayRemoveActiveMagicEffect(ActiveMagicEffect[] akArray, ActiveMagicEffect akValue, bool abSort = false) Global
  Int i = 0 ; #DEBUG_LINE_NO:215
  While i < akArray.Length ; #DEBUG_LINE_NO:216
    If akArray[i] == akValue ; #DEBUG_LINE_NO:217
      akArray[i] = None ; #DEBUG_LINE_NO:218
      If abSort == True ; #DEBUG_LINE_NO:219
        CommonArrayHelper.ArraySortActiveMagicEffect(akArray, 0) ; #DEBUG_LINE_NO:220
      EndIf
      Return True ; #DEBUG_LINE_NO:222
    Else
      i += 1 ; #DEBUG_LINE_NO:224
    EndIf
  EndWhile
  Return False ; #DEBUG_LINE_NO:228
EndFunction

Bool Function ArrayRemoveFormList(FormList[] akArray, FormList akValue, bool abSort = false) Global
  Int i = 0 ; #DEBUG_LINE_NO:237
  While i < akArray.Length ; #DEBUG_LINE_NO:238
    If akArray[i] == akValue ; #DEBUG_LINE_NO:239
      akArray[i] = None ; #DEBUG_LINE_NO:240
      If abSort == True ; #DEBUG_LINE_NO:241
        CommonArrayHelper.ArraySortFormList(akArray, 0) ; #DEBUG_LINE_NO:242
      EndIf
      Return True ; #DEBUG_LINE_NO:244
    Else
      i += 1 ; #DEBUG_LINE_NO:246
    EndIf
  EndWhile
  Return False ; #DEBUG_LINE_NO:250
EndFunction

Bool Function ArrayRemoveMessage(Message[] akArray, Message akValue, bool abSort = false) Global
  Int i = 0 ; #DEBUG_LINE_NO:259
  While i < akArray.Length ; #DEBUG_LINE_NO:260
    If akArray[i] == akValue ; #DEBUG_LINE_NO:261
      akArray[i] = None ; #DEBUG_LINE_NO:262
      If abSort == True ; #DEBUG_LINE_NO:263
        CommonArrayHelper.ArraySortMessage(akArray, 0) ; #DEBUG_LINE_NO:264
      EndIf
      Return True ; #DEBUG_LINE_NO:266
    Else
      i += 1 ; #DEBUG_LINE_NO:268
    EndIf
  EndWhile
  Return False ; #DEBUG_LINE_NO:272
EndFunction

Bool Function ArrayRemoveArmor(Armor[] akArray, Armor akValue, bool abSort = false) Global
  Int i = 0 ; #DEBUG_LINE_NO:281
  While i < akArray.Length ; #DEBUG_LINE_NO:282
    If akArray[i] == akValue ; #DEBUG_LINE_NO:283
      akArray[i] = None ; #DEBUG_LINE_NO:284
      If abSort == True ; #DEBUG_LINE_NO:285
        CommonArrayHelper.ArraySortArmor(akArray, 0) ; #DEBUG_LINE_NO:286
      EndIf
      Return True ; #DEBUG_LINE_NO:288
    Else
      i += 1 ; #DEBUG_LINE_NO:290
    EndIf
  EndWhile
  Return False ; #DEBUG_LINE_NO:294
EndFunction

Bool Function ArraySortForm(Form[] akArray, int i = 0) Global
  Bool bFirstNoneFound = False ; #DEBUG_LINE_NO:303
  Int iFirstNonePos = i ; #DEBUG_LINE_NO:304
  While i < akArray.Length ; #DEBUG_LINE_NO:305
    If CommonArrayHelper.IsNone(akArray[i]) ; #DEBUG_LINE_NO:306
      akArray[i] = None ; #DEBUG_LINE_NO:307
      If bFirstNoneFound == False ; #DEBUG_LINE_NO:308
        bFirstNoneFound = True ; #DEBUG_LINE_NO:309
        iFirstNonePos = i ; #DEBUG_LINE_NO:310
        i += 1 ; #DEBUG_LINE_NO:311
      Else
        i += 1 ; #DEBUG_LINE_NO:313
      EndIf
    ElseIf bFirstNoneFound == True ; #DEBUG_LINE_NO:316
      If !CommonArrayHelper.IsNone(akArray[i]) ; #DEBUG_LINE_NO:318
        akArray[iFirstNonePos] = akArray[i] ; #DEBUG_LINE_NO:319
        akArray[i] = None ; #DEBUG_LINE_NO:320
        CommonArrayHelper.ArraySortForm(akArray, iFirstNonePos + 1) ; #DEBUG_LINE_NO:323
        Return True ; #DEBUG_LINE_NO:324
      Else
        i += 1 ; #DEBUG_LINE_NO:326
      EndIf
    Else
      i += 1 ; #DEBUG_LINE_NO:329
    EndIf
  EndWhile
  Return False ; #DEBUG_LINE_NO:333
EndFunction

Bool Function ArraySortArmor(Armor[] akArray, int i = 0) Global
  Bool bFirstNoneFound = False ; #DEBUG_LINE_NO:341
  Int iFirstNonePos = i ; #DEBUG_LINE_NO:342
  While i < akArray.Length ; #DEBUG_LINE_NO:343
    If CommonArrayHelper.IsNone(akArray[i] as Form) ; #DEBUG_LINE_NO:344
      akArray[i] = None ; #DEBUG_LINE_NO:345
      If bFirstNoneFound == False ; #DEBUG_LINE_NO:346
        bFirstNoneFound = True ; #DEBUG_LINE_NO:347
        iFirstNonePos = i ; #DEBUG_LINE_NO:348
        i += 1 ; #DEBUG_LINE_NO:349
      Else
        i += 1 ; #DEBUG_LINE_NO:351
      EndIf
    ElseIf bFirstNoneFound == True ; #DEBUG_LINE_NO:354
      If !CommonArrayHelper.IsNone(akArray[i] as Form) ; #DEBUG_LINE_NO:356
        akArray[iFirstNonePos] = akArray[i] ; #DEBUG_LINE_NO:357
        akArray[i] = None ; #DEBUG_LINE_NO:358
        CommonArrayHelper.ArraySortArmor(akArray, iFirstNonePos + 1) ; #DEBUG_LINE_NO:361
        Return True ; #DEBUG_LINE_NO:362
      Else
        i += 1 ; #DEBUG_LINE_NO:364
      EndIf
    Else
      i += 1 ; #DEBUG_LINE_NO:367
    EndIf
  EndWhile
  Return False ; #DEBUG_LINE_NO:371
EndFunction

Bool Function ArraySortActivator(Activator[] akArray, int i = 0) Global
  Bool bFirstNoneFound = False ; #DEBUG_LINE_NO:379
  Int iFirstNonePos = i ; #DEBUG_LINE_NO:380
  While i < akArray.Length ; #DEBUG_LINE_NO:381
    If CommonArrayHelper.IsNone(akArray[i] as Form) ; #DEBUG_LINE_NO:382
      akArray[i] = None ; #DEBUG_LINE_NO:383
      If bFirstNoneFound == False ; #DEBUG_LINE_NO:384
        bFirstNoneFound = True ; #DEBUG_LINE_NO:385
        iFirstNonePos = i ; #DEBUG_LINE_NO:386
        i += 1 ; #DEBUG_LINE_NO:387
      Else
        i += 1 ; #DEBUG_LINE_NO:389
      EndIf
    ElseIf bFirstNoneFound == True ; #DEBUG_LINE_NO:392
      If !CommonArrayHelper.IsNone(akArray[i] as Form) ; #DEBUG_LINE_NO:394
        akArray[iFirstNonePos] = akArray[i] ; #DEBUG_LINE_NO:395
        akArray[i] = None ; #DEBUG_LINE_NO:396
        CommonArrayHelper.ArraySortActivator(akArray, iFirstNonePos + 1) ; #DEBUG_LINE_NO:399
        Return True ; #DEBUG_LINE_NO:400
      Else
        i += 1 ; #DEBUG_LINE_NO:402
      EndIf
    Else
      i += 1 ; #DEBUG_LINE_NO:405
    EndIf
  EndWhile
  Return False ; #DEBUG_LINE_NO:409
EndFunction

Bool Function ArraySortMessage(Message[] akArray, int i = 0) Global
  Bool bFirstNoneFound = False ; #DEBUG_LINE_NO:416
  Int iFirstNonePos = i ; #DEBUG_LINE_NO:417
  While i < akArray.Length ; #DEBUG_LINE_NO:418
    If CommonArrayHelper.IsNone(akArray[i] as Form) ; #DEBUG_LINE_NO:419
      akArray[i] = None ; #DEBUG_LINE_NO:420
      If bFirstNoneFound == False ; #DEBUG_LINE_NO:421
        bFirstNoneFound = True ; #DEBUG_LINE_NO:422
        iFirstNonePos = i ; #DEBUG_LINE_NO:423
        i += 1 ; #DEBUG_LINE_NO:424
      Else
        i += 1 ; #DEBUG_LINE_NO:426
      EndIf
    ElseIf bFirstNoneFound == True ; #DEBUG_LINE_NO:429
      If !CommonArrayHelper.IsNone(akArray[i] as Form) ; #DEBUG_LINE_NO:431
        akArray[iFirstNonePos] = akArray[i] ; #DEBUG_LINE_NO:432
        akArray[i] = None ; #DEBUG_LINE_NO:433
        CommonArrayHelper.ArraySortMessage(akArray, iFirstNonePos + 1) ; #DEBUG_LINE_NO:436
        Return True ; #DEBUG_LINE_NO:437
      Else
        i += 1 ; #DEBUG_LINE_NO:439
      EndIf
    Else
      i += 1 ; #DEBUG_LINE_NO:442
    EndIf
  EndWhile
  Return False ; #DEBUG_LINE_NO:446
EndFunction

Bool Function ArraySortFormList(FormList[] akArray, int i = 0) Global
  Bool bFirstNoneFound = False ; #DEBUG_LINE_NO:453
  Int iFirstNonePos = i ; #DEBUG_LINE_NO:454
  While i < akArray.Length ; #DEBUG_LINE_NO:455
    If CommonArrayHelper.IsNone(akArray[i] as Form) ; #DEBUG_LINE_NO:456
      akArray[i] = None ; #DEBUG_LINE_NO:457
      If bFirstNoneFound == False ; #DEBUG_LINE_NO:458
        bFirstNoneFound = True ; #DEBUG_LINE_NO:459
        iFirstNonePos = i ; #DEBUG_LINE_NO:460
        i += 1 ; #DEBUG_LINE_NO:461
      Else
        i += 1 ; #DEBUG_LINE_NO:463
      EndIf
    ElseIf bFirstNoneFound == True ; #DEBUG_LINE_NO:466
      If !CommonArrayHelper.IsNone(akArray[i] as Form) ; #DEBUG_LINE_NO:468
        akArray[iFirstNonePos] = akArray[i] ; #DEBUG_LINE_NO:469
        akArray[i] = None ; #DEBUG_LINE_NO:470
        CommonArrayHelper.ArraySortFormList(akArray, iFirstNonePos + 1) ; #DEBUG_LINE_NO:472
        Return True ; #DEBUG_LINE_NO:473
      Else
        i += 1 ; #DEBUG_LINE_NO:475
      EndIf
    Else
      i += 1 ; #DEBUG_LINE_NO:478
    EndIf
  EndWhile
  Return False ; #DEBUG_LINE_NO:482
EndFunction

Bool Function ArraySortAlias(Alias[] akArray, int i = 0) Global
  Bool bFirstNoneFound = False ; #DEBUG_LINE_NO:489
  Int iFirstNonePos = i ; #DEBUG_LINE_NO:490
  While i < akArray.Length ; #DEBUG_LINE_NO:491
    If !akArray[i] ; #DEBUG_LINE_NO:492
      akArray[i] = None ; #DEBUG_LINE_NO:493
      If bFirstNoneFound == False ; #DEBUG_LINE_NO:494
        bFirstNoneFound = True ; #DEBUG_LINE_NO:495
        iFirstNonePos = i ; #DEBUG_LINE_NO:496
        i += 1 ; #DEBUG_LINE_NO:497
      Else
        i += 1 ; #DEBUG_LINE_NO:499
      EndIf
    ElseIf bFirstNoneFound == True ; #DEBUG_LINE_NO:502
      If akArray[i] ; #DEBUG_LINE_NO:504
        akArray[iFirstNonePos] = akArray[i] ; #DEBUG_LINE_NO:505
        akArray[i] = None ; #DEBUG_LINE_NO:506
        CommonArrayHelper.ArraySortAlias(akArray, iFirstNonePos + 1) ; #DEBUG_LINE_NO:508
        Return True ; #DEBUG_LINE_NO:509
      Else
        i += 1 ; #DEBUG_LINE_NO:511
      EndIf
    Else
      i += 1 ; #DEBUG_LINE_NO:514
    EndIf
  EndWhile
  Return False ; #DEBUG_LINE_NO:518
EndFunction

Bool Function ArraySortActiveMagicEffect(ActiveMagicEffect[] akArray, int i = 0) Global
  Bool bFirstNoneFound = False ; #DEBUG_LINE_NO:525
  Int iFirstNonePos = i ; #DEBUG_LINE_NO:526
  While i < akArray.Length ; #DEBUG_LINE_NO:527
    If !akArray[i] ; #DEBUG_LINE_NO:528
      akArray[i] = None ; #DEBUG_LINE_NO:529
      If bFirstNoneFound == False ; #DEBUG_LINE_NO:530
        bFirstNoneFound = True ; #DEBUG_LINE_NO:531
        iFirstNonePos = i ; #DEBUG_LINE_NO:532
        i += 1 ; #DEBUG_LINE_NO:533
      Else
        i += 1 ; #DEBUG_LINE_NO:535
      EndIf
    ElseIf bFirstNoneFound == True ; #DEBUG_LINE_NO:538
      If akArray[i] ; #DEBUG_LINE_NO:540
        akArray[iFirstNonePos] = akArray[i] ; #DEBUG_LINE_NO:541
        akArray[i] = None ; #DEBUG_LINE_NO:542
        CommonArrayHelper.ArraySortActiveMagicEffect(akArray, iFirstNonePos + 1) ; #DEBUG_LINE_NO:544
        Return True ; #DEBUG_LINE_NO:545
      Else
        i += 1 ; #DEBUG_LINE_NO:547
      EndIf
    Else
      i += 1 ; #DEBUG_LINE_NO:550
    EndIf
  EndWhile
  Return False ; #DEBUG_LINE_NO:554
EndFunction

Int Function ArrayCountForm(Form[] akArray) Global
  Int i = 0 ; #DEBUG_LINE_NO:561
  Int myCount = 0 ; #DEBUG_LINE_NO:562
  While i < akArray.Length ; #DEBUG_LINE_NO:563
    If !CommonArrayHelper.IsNone(akArray[i]) ; #DEBUG_LINE_NO:564
      myCount += 1 ; #DEBUG_LINE_NO:565
      i += 1 ; #DEBUG_LINE_NO:566
    Else
      i += 1 ; #DEBUG_LINE_NO:568
    EndIf
  EndWhile
  Return myCount ; #DEBUG_LINE_NO:571
EndFunction

Int Function ArrayCountAlias(Alias[] akArray) Global
  Int i = 0 ; #DEBUG_LINE_NO:578
  Int myCount = 0 ; #DEBUG_LINE_NO:579
  While i < akArray.Length ; #DEBUG_LINE_NO:580
    If akArray[i] != None ; #DEBUG_LINE_NO:581
      myCount += 1 ; #DEBUG_LINE_NO:582
      i += 1 ; #DEBUG_LINE_NO:583
    Else
      i += 1 ; #DEBUG_LINE_NO:585
    EndIf
  EndWhile
  Return myCount ; #DEBUG_LINE_NO:588
EndFunction

Int Function ArrayCountActiveMagicEffect(ActiveMagicEffect[] akArray) Global
  Int i = 0 ; #DEBUG_LINE_NO:595
  Int myCount = 0 ; #DEBUG_LINE_NO:596
  While i < akArray.Length ; #DEBUG_LINE_NO:597
    If akArray[i] != None ; #DEBUG_LINE_NO:598
      myCount += 1 ; #DEBUG_LINE_NO:599
      i += 1 ; #DEBUG_LINE_NO:600
    Else
      i += 1 ; #DEBUG_LINE_NO:602
    EndIf
  EndWhile
  Return myCount ; #DEBUG_LINE_NO:605
EndFunction

Int Function ArrayCountArmor(Armor[] akArray) Global
  Int i = 0 ; #DEBUG_LINE_NO:612
  Int myCount = 0 ; #DEBUG_LINE_NO:613
  While i < akArray.Length ; #DEBUG_LINE_NO:614
    If !CommonArrayHelper.IsNone(akArray[i] as Form) ; #DEBUG_LINE_NO:615
      myCount += 1 ; #DEBUG_LINE_NO:616
      i += 1 ; #DEBUG_LINE_NO:617
    Else
      i += 1 ; #DEBUG_LINE_NO:619
    EndIf
  EndWhile
  Return myCount ; #DEBUG_LINE_NO:622
EndFunction

Int Function ArrayCountActivator(Activator[] akArray) Global
  Int i = 0 ; #DEBUG_LINE_NO:629
  Int myCount = 0 ; #DEBUG_LINE_NO:630
  While i < akArray.Length ; #DEBUG_LINE_NO:631
    If !CommonArrayHelper.IsNone(akArray[i] as Form) ; #DEBUG_LINE_NO:632
      myCount += 1 ; #DEBUG_LINE_NO:633
      i += 1 ; #DEBUG_LINE_NO:634
    Else
      i += 1 ; #DEBUG_LINE_NO:636
    EndIf
  EndWhile
  Return myCount ; #DEBUG_LINE_NO:639
EndFunction

Int Function ArrayCountRef(ObjectReference[] akArray) Global
  Int i = 0 ; #DEBUG_LINE_NO:646
  Int myCount = 0 ; #DEBUG_LINE_NO:647
  While i < akArray.Length ; #DEBUG_LINE_NO:648
    If akArray[i] != None ; #DEBUG_LINE_NO:649
      myCount += 1 ; #DEBUG_LINE_NO:650
      i += 1 ; #DEBUG_LINE_NO:651
    Else
      i += 1 ; #DEBUG_LINE_NO:653
    EndIf
  EndWhile
  Return myCount ; #DEBUG_LINE_NO:656
EndFunction

Bool Function IsNone(Form akForm) Global
  Int i = 0 ; #DEBUG_LINE_NO:664
  If akForm ; #DEBUG_LINE_NO:665
    i = akForm.GetFormID() ; #DEBUG_LINE_NO:666
    If i == 0 ; #DEBUG_LINE_NO:667
      Return True ; #DEBUG_LINE_NO:668
    Else
      Return False ; #DEBUG_LINE_NO:670
    EndIf
  Else
    Return True ; #DEBUG_LINE_NO:673
  EndIf
EndFunction

Bool Function LinkedArrayAddArmor(Armor akArmor, Armor[] akArray1, Armor[] akArray2, Armor[] akArray3, Armor[] akArray4, Bool abTryInvalidRemoval = true) Global
  Int idx = -1 ; #DEBUG_LINE_NO:685
  idx = akArray1.find(None, 0) ; #DEBUG_LINE_NO:686
  If idx != -1 ; #DEBUG_LINE_NO:687
    akArray1[idx] = akArmor ; #DEBUG_LINE_NO:688
    Return True ; #DEBUG_LINE_NO:689
  EndIf
  idx = -1 ; #DEBUG_LINE_NO:692
  idx = akArray2.find(None, 0) ; #DEBUG_LINE_NO:693
  If idx != -1 ; #DEBUG_LINE_NO:694
    akArray2[idx] = akArmor ; #DEBUG_LINE_NO:695
    Return True ; #DEBUG_LINE_NO:696
  EndIf
  idx = -1 ; #DEBUG_LINE_NO:699
  idx = akArray3.find(None, 0) ; #DEBUG_LINE_NO:700
  If idx != -1 ; #DEBUG_LINE_NO:701
    akArray3[idx] = akArmor ; #DEBUG_LINE_NO:702
    Return True ; #DEBUG_LINE_NO:703
  EndIf
  idx = -1 ; #DEBUG_LINE_NO:706
  idx = akArray4.find(None, 0) ; #DEBUG_LINE_NO:707
  If idx != -1 ; #DEBUG_LINE_NO:708
    akArray4[idx] = akArmor ; #DEBUG_LINE_NO:709
    Return True ; #DEBUG_LINE_NO:710
  EndIf
  If abTryInvalidRemoval ; #DEBUG_LINE_NO:714
    Bool foundInvalidArmors = CommonArrayHelper.LinkedArrayRemoveInvalidArmors(akArray1, akArray2, akArray3, akArray4) ; #DEBUG_LINE_NO:715
    If foundInvalidArmors ; #DEBUG_LINE_NO:716
      Return CommonArrayHelper.LinkedArrayAddArmor(akArmor, akArray1, akArray2, akArray3, akArray4, True) ; #DEBUG_LINE_NO:717
    Else
      Return False ; #DEBUG_LINE_NO:719
    EndIf
  Else
    Return False ; #DEBUG_LINE_NO:722
  EndIf
EndFunction

Bool Function LinkedArrayRemoveArmor(Armor akArmor, Armor[] akArray1, Armor[] akArray2, Armor[] akArray3, Armor[] akArray4, Bool abSort = true) Global
  Int idx = -1 ; #DEBUG_LINE_NO:733
  idx = akArray1.find(akArmor, 0) ; #DEBUG_LINE_NO:734
  If idx != -1 ; #DEBUG_LINE_NO:735
    akArray1[idx] = None ; #DEBUG_LINE_NO:736
    If abSort ; #DEBUG_LINE_NO:737
      CommonArrayHelper.LinkedArraySortArmors(akArray1, akArray2, akArray3, akArray4, 0) ; #DEBUG_LINE_NO:738
    EndIf
    Return True ; #DEBUG_LINE_NO:740
  EndIf
  idx = -1 ; #DEBUG_LINE_NO:743
  idx = akArray2.find(akArmor, 0) ; #DEBUG_LINE_NO:744
  If idx != -1 ; #DEBUG_LINE_NO:745
    akArray2[idx] = None ; #DEBUG_LINE_NO:746
    If abSort ; #DEBUG_LINE_NO:747
      CommonArrayHelper.LinkedArraySortArmors(akArray1, akArray2, akArray3, akArray4, 0) ; #DEBUG_LINE_NO:748
    EndIf
    Return True ; #DEBUG_LINE_NO:750
  EndIf
  idx = -1 ; #DEBUG_LINE_NO:753
  idx = akArray3.find(akArmor, 0) ; #DEBUG_LINE_NO:754
  If idx != -1 ; #DEBUG_LINE_NO:755
    akArray3[idx] = None ; #DEBUG_LINE_NO:756
    If abSort ; #DEBUG_LINE_NO:757
      CommonArrayHelper.LinkedArraySortArmors(akArray1, akArray2, akArray3, akArray4, 0) ; #DEBUG_LINE_NO:758
    EndIf
    Return True ; #DEBUG_LINE_NO:760
  EndIf
  idx = -1 ; #DEBUG_LINE_NO:763
  idx = akArray4.find(akArmor, 0) ; #DEBUG_LINE_NO:764
  If idx != -1 ; #DEBUG_LINE_NO:765
    akArray4[idx] = None ; #DEBUG_LINE_NO:766
    If abSort ; #DEBUG_LINE_NO:767
      CommonArrayHelper.LinkedArraySortArmors(akArray1, akArray2, akArray3, akArray4, 0) ; #DEBUG_LINE_NO:768
    EndIf
    Return True ; #DEBUG_LINE_NO:770
  EndIf
  Return False ; #DEBUG_LINE_NO:773
EndFunction

Bool Function LinkedArrayHasArmor(Armor akArmor, Armor[] akArray1, Armor[] akArray2, Armor[] akArray3, Armor[] akArray4) Global
  If akArray1.find(akArmor, 0) != -1 ; #DEBUG_LINE_NO:783
    Return True ; #DEBUG_LINE_NO:784
  ElseIf akArray2.find(akArmor, 0) != -1 ; #DEBUG_LINE_NO:785
    Return True ; #DEBUG_LINE_NO:786
  ElseIf akArray3.find(akArmor, 0) != -1 ; #DEBUG_LINE_NO:787
    Return True ; #DEBUG_LINE_NO:788
  ElseIf akArray4.find(akArmor, 0) != -1 ; #DEBUG_LINE_NO:789
    Return True ; #DEBUG_LINE_NO:790
  Else
    Return False ; #DEBUG_LINE_NO:792
  EndIf
EndFunction

Function LinkedArrayClearArmors128(Armor[] akArray1, Armor[] akArray2, Armor[] akArray3, Armor[] akArray4) Global
  akArray1 = new Armor[128] ; #DEBUG_LINE_NO:802
  akArray2 = new Armor[128] ; #DEBUG_LINE_NO:803
  akArray3 = new Armor[128] ; #DEBUG_LINE_NO:804
  akArray4 = new Armor[128] ; #DEBUG_LINE_NO:805
EndFunction

Bool Function LinkedArrayRemoveInvalidArmors(Armor[] akArray1, Armor[] akArray2, Armor[] akArray3, Armor[] akArray4) Global
  Bool foundInvalidArmor = False ; #DEBUG_LINE_NO:814
  Int i = 0 ; #DEBUG_LINE_NO:815
  While i < akArray1.Length ; #DEBUG_LINE_NO:816
    If akArray1[i] as String == "[Armor <None>]" ; #DEBUG_LINE_NO:817
      akArray1[i] = None ; #DEBUG_LINE_NO:818
      foundInvalidArmor = True ; #DEBUG_LINE_NO:819
    EndIf
    i += 1 ; #DEBUG_LINE_NO:821
  EndWhile
  i = 0 ; #DEBUG_LINE_NO:824
  While i < akArray2.Length ; #DEBUG_LINE_NO:825
    If akArray2[i] as String == "[Armor <None>]" ; #DEBUG_LINE_NO:826
      akArray2[i] = None ; #DEBUG_LINE_NO:827
      foundInvalidArmor = True ; #DEBUG_LINE_NO:828
    EndIf
    i += 1 ; #DEBUG_LINE_NO:830
  EndWhile
  i = 0 ; #DEBUG_LINE_NO:833
  While i < akArray3.Length ; #DEBUG_LINE_NO:834
    If akArray3[i] as String == "[Armor <None>]" ; #DEBUG_LINE_NO:835
      akArray3[i] = None ; #DEBUG_LINE_NO:836
      foundInvalidArmor = True ; #DEBUG_LINE_NO:837
    EndIf
    i += 1 ; #DEBUG_LINE_NO:839
  EndWhile
  i = 0 ; #DEBUG_LINE_NO:842
  While i < akArray4.Length ; #DEBUG_LINE_NO:843
    If akArray4[i] as String == "[Armor <None>]" ; #DEBUG_LINE_NO:844
      akArray4[i] = None ; #DEBUG_LINE_NO:845
      foundInvalidArmor = True ; #DEBUG_LINE_NO:846
    EndIf
    i += 1 ; #DEBUG_LINE_NO:848
  EndWhile
  If foundInvalidArmor ; #DEBUG_LINE_NO:851
    CommonArrayHelper.LinkedArraySortArmors(akArray1, akArray2, akArray3, akArray4, 0) ; #DEBUG_LINE_NO:852
    Return True ; #DEBUG_LINE_NO:853
  Else
    Return False ; #DEBUG_LINE_NO:855
  EndIf
EndFunction

Int Function LinkedArrayCountArmors(Armor[] akArray1, Armor[] akArray2, Armor[] akArray3, Armor[] akArray4) Global
  Int myCount = 0 ; #DEBUG_LINE_NO:865
  Int i = 0 ; #DEBUG_LINE_NO:867
  While i < akArray1.Length ; #DEBUG_LINE_NO:868
    If akArray1[i] != None ; #DEBUG_LINE_NO:869
      myCount += 1 ; #DEBUG_LINE_NO:870
      i += 1 ; #DEBUG_LINE_NO:871
    Else
      i += 1 ; #DEBUG_LINE_NO:873
    EndIf
  EndWhile
  i = 0 ; #DEBUG_LINE_NO:877
  While i < akArray2.Length ; #DEBUG_LINE_NO:878
    If akArray2[i] != None ; #DEBUG_LINE_NO:879
      myCount += 1 ; #DEBUG_LINE_NO:880
      i += 1 ; #DEBUG_LINE_NO:881
    Else
      i += 1 ; #DEBUG_LINE_NO:883
    EndIf
  EndWhile
  i = 0 ; #DEBUG_LINE_NO:887
  While i < akArray3.Length ; #DEBUG_LINE_NO:888
    If akArray3[i] != None ; #DEBUG_LINE_NO:889
      myCount += 1 ; #DEBUG_LINE_NO:890
      i += 1 ; #DEBUG_LINE_NO:891
    Else
      i += 1 ; #DEBUG_LINE_NO:893
    EndIf
  EndWhile
  i = 0 ; #DEBUG_LINE_NO:897
  While i < akArray4.Length ; #DEBUG_LINE_NO:898
    If akArray4[i] != None ; #DEBUG_LINE_NO:899
      myCount += 1 ; #DEBUG_LINE_NO:900
      i += 1 ; #DEBUG_LINE_NO:901
    Else
      i += 1 ; #DEBUG_LINE_NO:903
    EndIf
  EndWhile
  Return myCount ; #DEBUG_LINE_NO:907
EndFunction

Bool Function LinkedArraySortArmors(Armor[] akArray1, Armor[] akArray2, Armor[] akArray3, Armor[] akArray4, Int i = 0) Global
  Bool firstNoneFound = False ; #DEBUG_LINE_NO:920
  Int firstNoneFoundArrayId = 0 ; #DEBUG_LINE_NO:921
  Int firstNoneIndex = 0 ; #DEBUG_LINE_NO:922
  While i < 512 ; #DEBUG_LINE_NO:923
    Int myCurrArray
    Int j = 0 ; #DEBUG_LINE_NO:925
    If i < 128 ; #DEBUG_LINE_NO:927
      myCurrArray = 1 ; #DEBUG_LINE_NO:928
      j = i ; #DEBUG_LINE_NO:929
    ElseIf i < 256 && i >= 128 ; #DEBUG_LINE_NO:930
      j = i - 128 ; #DEBUG_LINE_NO:931
      myCurrArray = 2 ; #DEBUG_LINE_NO:932
    ElseIf i < 384 && i >= 256 ; #DEBUG_LINE_NO:933
      j = i - 256 ; #DEBUG_LINE_NO:934
      myCurrArray = 3 ; #DEBUG_LINE_NO:935
    ElseIf i < 512 && i >= 384 ; #DEBUG_LINE_NO:936
      j = i - 384 ; #DEBUG_LINE_NO:937
      myCurrArray = 4 ; #DEBUG_LINE_NO:938
    EndIf
    If myCurrArray == 1 ; #DEBUG_LINE_NO:941
      If akArray1[j] == None ; #DEBUG_LINE_NO:942
        If firstNoneFound == False ; #DEBUG_LINE_NO:943
          firstNoneFound = True ; #DEBUG_LINE_NO:944
          firstNoneFoundArrayId = myCurrArray ; #DEBUG_LINE_NO:945
          firstNoneIndex = j ; #DEBUG_LINE_NO:946
          i += 1 ; #DEBUG_LINE_NO:947
        Else
          i += 1 ; #DEBUG_LINE_NO:949
        EndIf
      ElseIf firstNoneFound == True ; #DEBUG_LINE_NO:952
        If akArray1[j] != None ; #DEBUG_LINE_NO:954
          If firstNoneFoundArrayId == 1 ; #DEBUG_LINE_NO:956
            akArray1[firstNoneIndex] = akArray1[j] ; #DEBUG_LINE_NO:957
            akArray1[j] = None ; #DEBUG_LINE_NO:958
          ElseIf firstNoneFoundArrayId == 2 ; #DEBUG_LINE_NO:959
            akArray2[firstNoneIndex] = akArray1[j] ; #DEBUG_LINE_NO:960
            akArray1[j] = None ; #DEBUG_LINE_NO:961
          ElseIf firstNoneFoundArrayId == 3 ; #DEBUG_LINE_NO:962
            akArray3[firstNoneIndex] = akArray1[j] ; #DEBUG_LINE_NO:963
            akArray1[j] = None ; #DEBUG_LINE_NO:964
          ElseIf firstNoneFoundArrayId == 4 ; #DEBUG_LINE_NO:965
            akArray4[firstNoneIndex] = akArray1[j] ; #DEBUG_LINE_NO:966
            akArray1[j] = None ; #DEBUG_LINE_NO:967
          EndIf
          CommonArrayHelper.LinkedArraySortArmors(akArray1, akArray2, akArray3, akArray4, firstNoneIndex + 1) ; #DEBUG_LINE_NO:970
          Return True ; #DEBUG_LINE_NO:971
        Else
          i += 1 ; #DEBUG_LINE_NO:973
        EndIf
      Else
        i += 1 ; #DEBUG_LINE_NO:976
      EndIf
    ElseIf myCurrArray == 2 ; #DEBUG_LINE_NO:979
      If akArray2[j] == None ; #DEBUG_LINE_NO:980
        If firstNoneFound == False ; #DEBUG_LINE_NO:981
          firstNoneFound = True ; #DEBUG_LINE_NO:982
          firstNoneFoundArrayId = myCurrArray ; #DEBUG_LINE_NO:983
          firstNoneIndex = j ; #DEBUG_LINE_NO:984
          i += 1 ; #DEBUG_LINE_NO:985
        Else
          i += 1 ; #DEBUG_LINE_NO:987
        EndIf
      ElseIf firstNoneFound == True ; #DEBUG_LINE_NO:990
        If akArray2[j] != None ; #DEBUG_LINE_NO:992
          If firstNoneFoundArrayId == 1 ; #DEBUG_LINE_NO:994
            akArray1[firstNoneIndex] = akArray2[j] ; #DEBUG_LINE_NO:995
            akArray2[j] = None ; #DEBUG_LINE_NO:996
          ElseIf firstNoneFoundArrayId == 2 ; #DEBUG_LINE_NO:997
            akArray2[firstNoneIndex] = akArray2[j] ; #DEBUG_LINE_NO:998
            akArray2[j] = None ; #DEBUG_LINE_NO:999
          ElseIf firstNoneFoundArrayId == 3 ; #DEBUG_LINE_NO:1000
            akArray3[firstNoneIndex] = akArray2[j] ; #DEBUG_LINE_NO:1001
            akArray2[j] = None ; #DEBUG_LINE_NO:1002
          ElseIf firstNoneFoundArrayId == 4 ; #DEBUG_LINE_NO:1003
            akArray4[firstNoneIndex] = akArray2[j] ; #DEBUG_LINE_NO:1004
            akArray2[j] = None ; #DEBUG_LINE_NO:1005
          EndIf
          CommonArrayHelper.LinkedArraySortArmors(akArray1, akArray2, akArray3, akArray4, firstNoneIndex + 1) ; #DEBUG_LINE_NO:1008
          Return True ; #DEBUG_LINE_NO:1009
        Else
          i += 1 ; #DEBUG_LINE_NO:1011
        EndIf
      Else
        i += 1 ; #DEBUG_LINE_NO:1014
      EndIf
    ElseIf myCurrArray == 3 ; #DEBUG_LINE_NO:1017
      If akArray3[j] == None ; #DEBUG_LINE_NO:1018
        If firstNoneFound == False ; #DEBUG_LINE_NO:1019
          firstNoneFound = True ; #DEBUG_LINE_NO:1020
          firstNoneFoundArrayId = myCurrArray ; #DEBUG_LINE_NO:1021
          firstNoneIndex = j ; #DEBUG_LINE_NO:1022
          i += 1 ; #DEBUG_LINE_NO:1023
        Else
          i += 1 ; #DEBUG_LINE_NO:1025
        EndIf
      ElseIf firstNoneFound == True ; #DEBUG_LINE_NO:1028
        If akArray3[j] != None ; #DEBUG_LINE_NO:1030
          If firstNoneFoundArrayId == 1 ; #DEBUG_LINE_NO:1032
            akArray1[firstNoneIndex] = akArray3[j] ; #DEBUG_LINE_NO:1033
            akArray3[j] = None ; #DEBUG_LINE_NO:1034
          ElseIf firstNoneFoundArrayId == 2 ; #DEBUG_LINE_NO:1035
            akArray2[firstNoneIndex] = akArray3[j] ; #DEBUG_LINE_NO:1036
            akArray3[j] = None ; #DEBUG_LINE_NO:1037
          ElseIf firstNoneFoundArrayId == 3 ; #DEBUG_LINE_NO:1038
            akArray3[firstNoneIndex] = akArray3[j] ; #DEBUG_LINE_NO:1039
            akArray3[j] = None ; #DEBUG_LINE_NO:1040
          ElseIf firstNoneFoundArrayId == 4 ; #DEBUG_LINE_NO:1041
            akArray4[firstNoneIndex] = akArray3[j] ; #DEBUG_LINE_NO:1042
            akArray3[j] = None ; #DEBUG_LINE_NO:1043
          EndIf
          CommonArrayHelper.LinkedArraySortArmors(akArray1, akArray2, akArray3, akArray4, firstNoneIndex + 1) ; #DEBUG_LINE_NO:1046
          Return True ; #DEBUG_LINE_NO:1047
        Else
          i += 1 ; #DEBUG_LINE_NO:1049
        EndIf
      Else
        i += 1 ; #DEBUG_LINE_NO:1052
      EndIf
    ElseIf myCurrArray == 4 ; #DEBUG_LINE_NO:1055
      If akArray4[j] == None ; #DEBUG_LINE_NO:1056
        If firstNoneFound == False ; #DEBUG_LINE_NO:1057
          firstNoneFound = True ; #DEBUG_LINE_NO:1058
          firstNoneFoundArrayId = myCurrArray ; #DEBUG_LINE_NO:1059
          firstNoneIndex = j ; #DEBUG_LINE_NO:1060
          i += 1 ; #DEBUG_LINE_NO:1061
        Else
          i += 1 ; #DEBUG_LINE_NO:1063
        EndIf
      ElseIf firstNoneFound == True ; #DEBUG_LINE_NO:1066
        If akArray4[j] != None ; #DEBUG_LINE_NO:1068
          If firstNoneFoundArrayId == 1 ; #DEBUG_LINE_NO:1070
            akArray1[firstNoneIndex] = akArray4[j] ; #DEBUG_LINE_NO:1071
            akArray4[j] = None ; #DEBUG_LINE_NO:1072
          ElseIf firstNoneFoundArrayId == 2 ; #DEBUG_LINE_NO:1073
            akArray2[firstNoneIndex] = akArray4[j] ; #DEBUG_LINE_NO:1074
            akArray4[j] = None ; #DEBUG_LINE_NO:1075
          ElseIf firstNoneFoundArrayId == 3 ; #DEBUG_LINE_NO:1076
            akArray3[firstNoneIndex] = akArray4[j] ; #DEBUG_LINE_NO:1077
            akArray4[j] = None ; #DEBUG_LINE_NO:1078
          ElseIf firstNoneFoundArrayId == 4 ; #DEBUG_LINE_NO:1079
            akArray4[firstNoneIndex] = akArray4[j] ; #DEBUG_LINE_NO:1080
            akArray4[j] = None ; #DEBUG_LINE_NO:1081
          EndIf
          CommonArrayHelper.LinkedArraySortArmors(akArray1, akArray2, akArray3, akArray4, firstNoneIndex + 1) ; #DEBUG_LINE_NO:1084
          Return True ; #DEBUG_LINE_NO:1085
        Else
          i += 1 ; #DEBUG_LINE_NO:1087
        EndIf
      Else
        i += 1 ; #DEBUG_LINE_NO:1090
      EndIf
    EndIf
  EndWhile
  Return False ; #DEBUG_LINE_NO:1096
EndFunction
