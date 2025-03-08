using UnityEngine;
using UnityEngine.SceneManagement;

public class FinalScene : MonoBehaviour
{
    [SerializeField] private Animator fadeAnim;
    [SerializeField] private ParticleSystem puff;
    [SerializeField] private AudioSource mainTheme;
    [SerializeField] private MusicFader musicFader;

    void Start()
    {
        Application.targetFrameRate = 60;
        QualitySettings.vSyncCount = 0;
    }
    public void CSPuff(){
        puff.Play();
    }
    public void LoadMenu(){
        musicFader.FadeOutMusic(mainTheme);
        fadeAnim.SetTrigger("Fade");
        Invoke("LoadMenuScene", 2);
    }
    void LoadMenuScene(){
        SceneManager.LoadScene("Menu");
    }
}
