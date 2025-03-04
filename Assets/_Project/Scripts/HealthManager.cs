using UnityEngine;

public class HealthManager : MonoBehaviour
{
    [SerializeField] private GameObject healthUI;
    private PlayerController playerController;
    [SerializeField] private GameManager gameManager;

    [SerializeField] private int currentHP = 6;

    [System.Serializable]
    public class hpIcon{
        public GameObject full;
        public GameObject half;
    }
    [SerializeField] private hpIcon[] hpIcons;
    private bool dead;

    public void Init(PlayerController _playerController){
        currentHP = 6;
        playerController = _playerController;
        dead = false;
        healthUI.SetActive(false);
        for(int i = 0; i < 3; i++){
            hpIcons[i].full.SetActive(true);
            hpIcons[i].half.SetActive(false);
        }
    }

    public void TakeDamage(){
        if (dead) return;
        if (currentHP == 6) healthUI.SetActive(true);

        currentHP--;
        
        if (currentHP == 0){
            dead = true;
            playerController.Die();
            Invoke("RestartLvl", 2.5f);
        }

        for(int i = 0; i < 6 - currentHP; i++){
            int idx = 3 - (int)(i / 2) - 1;
            if (i % 2 == 0){
                hpIcons[idx].full.SetActive(false);
                hpIcons[idx].half.SetActive(true);
            }
            else{
                hpIcons[idx].half.SetActive(false);
            }
        }
    }

    void RestartLvl(){
        healthUI.SetActive(false);
        gameManager.LvlFailed();
    }
}
