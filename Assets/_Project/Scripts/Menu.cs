using TMPro;
using UnityEngine;
using UnityEngine.Audio;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class Menu : MonoBehaviour
{
    [SerializeField] private Animator fade;
    [SerializeField] private GameObject inDevObj;
    [SerializeField] private ParticleSystem puff;
    [SerializeField] private GameObject settingsObj;

    [SerializeField] private Slider slider;
    [SerializeField] private TMP_Text sliderText;
    [SerializeField] private AudioMixer audioMixer;

    [SerializeField] private AudioSource mainAudio;
    [SerializeField] private MusicFader musicFader;

    void Start()
    {
        Application.targetFrameRate = 60;
        QualitySettings.vSyncCount = 0;

        sliderText.text = "" + PlayerPrefs.GetFloat("PlayerVolume", 1).ToString("F1");
        slider.value = PlayerPrefs.GetFloat("PlayerVolume", 1);
    }

    public void CSPuff(){
        puff.Play();
    }

    public void PlayButton(){
        fade.SetTrigger("Fade");
        musicFader.FadeOutMusic(mainAudio, 1);
        Invoke("GoToGame", 1.5f);
    }

    void GoToGame(){
        SceneManager.LoadScene("Game");
    }

    public void InDevelopment(){
        CancelInvoke("hideInDev");
        inDevObj.SetActive(true);
        Invoke("hideInDev", 3);
    }
    void hideInDev(){
        inDevObj.SetActive(false);
    }

    public void SettingsButton(){
        settingsObj.SetActive(!settingsObj.activeSelf);
    }
    public void CloseSettings(){
        Invoke("SettingsButton", 0.15f);
    }

    public void ChangeVolume(){
        PlayerPrefs.SetFloat("PlayerVolume", slider.value);
        sliderText.text = "" + slider.value.ToString("F1");

        audioMixer.SetFloat("Volume", Mathf.Log10(slider.value)*20);
    }
}
