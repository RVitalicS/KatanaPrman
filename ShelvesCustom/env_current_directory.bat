
@ECHO OFF

:: define current directory variable
SET CUR_DIR=%~dp0

:: exit if PYTHONPATH has current directory
FOR %%x in (%PYTHONPATH%) do (

	IF "%%x" == "%CUR_DIR%" (
	    ECHO PYTHONPATH already has %%x
	    EXIT
	)

	IF "%%x" == "%CUR_DIR:~0,-1%" (
	    ECHO PYTHONPATH already has %%x
	    EXIT
	)
)

:: add current directory to PYTHONPATH environment variable
SETX PYTHONPATH "%CUR_DIR%;%PYTHONPATH%" /m
ECHO %CUR_DIR% have been added to PYTHTONPATH
