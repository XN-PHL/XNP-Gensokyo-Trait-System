# 0.5.60.6.11 Sanitized Evidence Excerpts

## Accepted 0.5.60.6.10 runtime evidence

```text
[XNP DISTANCE RUNNER] native CharacterTrait registered id=XNPFeastGuardianTrait:XNPFeastGuardian
[XNP TRAITS] distance_runner=true phoenix=true green=true red=true
[XNP RED TRAIT] full_id=XNPFeastGuardianTrait:XNPFeastGuardian detected=false method=NOT_FOUND
[XNP RED GUARDIAN] starter_grant=false reason=NO_TRAIT
[XNP TRAIT] detector_method=RESTORED_OBJECT_TRAIT_DETECTOR
[XNP TRAIT] CharacterTrait resolved
[XNP TRAIT] player has target trait=true
[XNP TRAIT] object_found=true alias_found=false matched_alias=none
```

## 0.5.60.6.11 repair expectation

The Red module no longer owns a separate trait scanner. It calls the additive `Core.Trait.DetectCharacterTrait` entry in the same detector module that produced the accepted object-detector evidence, explicitly passing the fixed Red Full ID and aliases.

Expected confirmation after user testing:

```text
[XNP RED TRAIT] full_id=XNPFeastGuardianTrait:XNPFeastGuardian detected=true method=RESTORED_OBJECT_TRAIT_DETECTOR
[XNP RED GUARDIAN] starter_grant=true count=3 once_key=XNP_RED_GUARDIAN_STARTER_GRANTED_0555 reason=NEW_CHARACTER
```

An existing affected character may report `reason=BROKEN_GATE_RECOVERY` instead. No raw console, local path, hardware data or unrelated module information is included here.

RUNTIME_STATUS=NOT_YET_TESTED
