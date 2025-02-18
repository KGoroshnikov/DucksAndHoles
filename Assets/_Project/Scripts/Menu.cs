using UnityEngine;
using UnityEngine.SceneManagement;

public class Menu : MonoBehaviour
{
    [SerializeField] private Animator fade;
    [SerializeField] private GameObject inDevObj;
    [SerializeField] private ParticleSystem puff;

    public void CSPuff(){
        puff.Play();
    }

    public void PlayButton(){
        fade.SetTrigger("Fade");
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
}
