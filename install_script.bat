REM Create a virtual environment
python -m venv myenv
 
REM Activate the virtual environment
call myenv\Scripts\activate
 
REM Install the required dependencies
pip install -r requirements.txt
 
REM Deactivate the virtual environment
deactivate
