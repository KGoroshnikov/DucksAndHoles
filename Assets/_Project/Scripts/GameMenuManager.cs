using UnityEngine;
using UnityEngine.SceneManagement;

public class GameMenuManager : MonoBehaviour
{
    [SerializeField] private GameObject exitDialogue;
    [SerializeField] private Animator animatorFade;

    public void StartExitDialogue(){
        Invoke("showDialogue", 0.2f);
    }

    void showDialogue(){
        Time.timeScale = 0.01f;
        exitDialogue.SetActive(true);
    }

    void closeDialogue(){
        exitDialogue.SetActive(false);
    }

    public void CloseDialogue(){
        Time.timeScale = 1f;
        Invoke("closeDialogue", 0.2f);
    }

    public void ExitToMenu(){
        Time.timeScale = 1f;
        animatorFade.SetTrigger("Fade");
        Invoke("exitToMenu", 1.5f);
    }

    void exitToMenu(){
        SceneManager.LoadScene("Menu");
    }
}
