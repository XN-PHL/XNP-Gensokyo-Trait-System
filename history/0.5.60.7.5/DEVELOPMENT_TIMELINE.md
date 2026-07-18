# Development timeline

1. Early Green-skill work explored engine entity/factory routes for the projectile; those assumptions were rejected in favor of a virtual pure-Lua visual route.
2. Earlier projection work exposed zoom-dependent and panel-space drift, especially where camera offsets could be applied more than once.
3. The draw API contract was audited and the projection was rebuilt around one camera-offset deduction, player zoom, and the selected player's viewport origin.
4. Impact was coupled to visible-flight proof: a successful draw, 500 ms minimum duration, and two drawn frames. Failure now prevents damage and refunds cooldown.
5. Target outline acquisition changed from broad enumeration to a bounded local square scan with ownership-safe cleanup.
6. The 0.5.60.7.5 source and Workshop mirror passed a second static audit and 101-file Kahlua checks with zero failures.
7. The user confirmed that the required functions are present. The version remains a runtime-test build because test-only defaults are enabled.

