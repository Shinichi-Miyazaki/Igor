#pragma TextEncoding = "Shift_JIS"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

function SHnormalization(CARSwv, xNum1,xNum2,yNum1,yNum2, SHwv)
wave CARSwv, SHwv
variable xNum1,xNum2,yNum1,yNum2;
Silent 1; PauseUpdate

duplicate/o/r = [xNum1, xNum2][yNum1, yNum2] CARSwv, tempwv
matrixop/o tempwv = mean(tempwv)
matrixop/o normalizedSH = SHwv / tempwv[0]

end