PRs welcome!

# STATUS UPDATE

I got Sesame to build with Gemma 3 without errors before I went to sleep finally, replacing the built in Llama 1B model. That's as far as I got, but Gemma 3 should be swapped in correctly now. 
I've uploaded all the updated relevant files to the repo, you should be able to go from here if you don't want to wait for me to put up step by step instructions for how I got to where I am.

Main points are: Swap Models.py with mine, launch the model via "python SesameConverse.py" once all dependencies are installed. You also need my generator.py. Lastly, **after** you install all the build requirements in requirements.txt (and others I still need to update it with), you must switch my "_model_builders.py" in the folder in the repo with the one that is created after torchtune is installed by default via the "pip install -r requirements.txt" command. 

All Gemma 3 values values in "_model_builders.py" for Gemma 3 models are placeholders (temp, etc), I'll leave tweaking that to find the best settings to you guys.


------------------------------------------------------------------

The script I'm working on is SesameConverse.py. It's currently a work in progress, but keep an eye on the repo for updates, I'll update the releases section once it's functional. Hopefully will have it working soon. The default model for text generation is going to be Gemma 3 12B. This will allow Sesame to have real-time conversations like the demo.

# Hugging Face Access Tokens

You must generate an access token here:

https://huggingface.co/settings/tokens

and use this command in the terminal:

"huggingface-cli login"

Then input your access token.

----------------------------------------------------
# Windows 11 Installation Instructions

To install and run the project on Windows 11 64-bit, follow these steps:

1. **Clone the repository:**

    ```bash
    git clone https://github.com/jazir555/SesameConverse.git

    cd csm
    ```

2. **Create and activate a virtual environment:**

    ```batch
    python -m venv myenv
    call myenv\Scripts\activate
    ```

3. **Install the required dependencies:**

    ```batch
    pip install -r requirements.txt
    ```

4. **Run the installation script:**

    We have provided a batch script `install_script.bat` to automate the setup process. You can run it by double-clicking on it or executing it from the command prompt.

    ```batch
    install_script.bat
    ```

5. **Run the script:**

    After the installation is complete, you can run the script `SesameConverse.py` by executing the following command in your terminal:

    ```bash
    python SesameConverse.py
    ```

    This will start the live voice AI conversation loop. Make sure your microphone is connected and configured correctly. You can say "exit" or "quit" to end the conversation.

6. **Configure the microphone:**

    To configure the microphone for `SesameConverse.py`, follow these steps:

    * Ensure you have the `speech_recognition` package installed, as it is required for microphone input. You can install it using the command `pip install SpeechRecognition`.
    * Open the `SesameConverse.py` file and locate the `select_microphone` function. This function lists available microphones and allows you to select one.
    * Run the script, and it will prompt you to select a microphone from the list of available devices. If you do not select a microphone, the default microphone will be used.
    * The selected microphone index is stored in the `mic_index` variable, which is then used in the `recognize_speech` function to capture audio input from the selected microphone.

    For more details, refer to the `SesameConverse.py` file.

## Windows 11 Compatibility

The project has been verified to be compatible with Windows 11 64-bit. The dependencies listed in the `requirements.txt` file are compatible with Windows 11. The provided `install_script.bat` automates the setup process, ensuring a smooth installation experience on Windows 11.

--------------------------------------------

# CSM

**2025/03/13** - We are releasing the 1B CSM variant. The checkpoint is [hosted on HuggingFace](https://huggingface.co/sesame/csm_1b).

---

CSM (Conversational Speech Model) is a speech generation model from [Sesame](sesame.com) that generates RVQ audio codes from text and audio inputs. The model architecture employs a [Llama](https://www.llama.com/) backbone and a smaller audio decoder that produces [Mimi](https://huggingface.co/kyutai/mimi) audio codes.

A fine-tuned variant of CSM powers the [interactive voice demo](https://www.sesame.com/voicedemo) shown in our [blog post](https://www.sesame.com/research/crossing_the_uncanny_valley_of_voice).

A hosted [HuggingFace space](https://huggingface.co/spaces/sesame/csm-1b) is also available for testing audio generation.

## Usage

Setup the repo

```bash
git clone git@github.com:SesameAILabs/csm.git
cd csm
python3.10 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Generate a sentence

```python
from huggingface_hub import hf_hub_download
from generator import load_csm_1b
import torchaudio

model_path = hf_hub_download(repo_id="sesame/csm-1b", filename="ckpt.pt")
generator = load_csm_1b(model_path, "cuda")
audio = generator.generate(
    text="Hello from Sesame.",
    speaker=0,
    context=[],
    max_audio_length_ms=10_000,
)

torchaudio.save("audio.wav", audio.unsqueeze(0).cpu(), generator.sample_rate)
```

CSM sounds best when provided with context. You can prompt or provide context to the model using a `Segment` for each speaker utterance.

```python
speakers = [0, 1, 0, 0]
transcripts = [
    "Hey how are you doing.",
    "Pretty good, pretty good.",
    "I'm great.",
    "So happy to be speaking to you.",
]
audio_paths = [
    "utterance_0.wav",
    "utterance_1.wav",
    "utterance_2.wav",
    "utterance_3.wav",
]

def load_audio(audio_path):
    audio_tensor, sample_rate = torchaudio.load(audio_path)
    audio_tensor = torchaudio.functional.resample(
        audio_tensor.squeeze(0), orig_freq=sample_rate, new_freq=generator.sample_rate
    )
    return audio_tensor

segments = [
    Segment(text=transcript, speaker=speaker, audio=load_audio(audio_path))
    for transcript, speaker, audio_path in zip(transcripts, speakers, audio_paths)
]
audio = generator.generate(
    text="Me too, this is some cool stuff huh?",
    speaker=1,
    context=segments,
    max_audio_length_ms=10_000,
)

torchaudio.save("audio.wav", audio.unsqueeze(0).cpu(), generator.sample_rate)
```

## FAQ

**Does this model come with any voices?**

The model open sourced here is a base generation model. It is capable of producing a variety of voices, but it has not been fine-tuned on any specific voice.

**Can I converse with the model?**

CSM is trained to be an audio generation model and not a general purpose multimodal LLM. It cannot generate text. We suggest using a separate LLM for text generation.

**Does it support other languages?**

The model has some capacity for non-English languages due to data contamination in the training data, but it likely won't do well.

## Misuse and abuse ⚠️

This project provides a high-quality speech generation model for research and educational purposes. While we encourage responsible and ethical use, we **explicitly prohibit** the following:

- **Impersonation or Fraud**: Do not use this model to generate speech that mimics real individuals without their explicit consent.
- **Misinformation or Deception**: Do not use this model to create deceptive or misleading content, such as fake news or fraudulent calls.
- **Illegal or Harmful Activities**: Do not use this model for any illegal, harmful, or malicious purposes.

By using this model, you agree to comply with all applicable laws and ethical guidelines. We are **not responsible** for any misuse, and we strongly condemn unethical applications of this technology.

**Authors**
Johan Schalkwyk, Ankit Kumar, Dan Lyth, Sefik Emre Eskimez, Zack Hodari, Cinjon Resnick, Ramon Sanabria, Raven Jiang, and the Sesame team.
