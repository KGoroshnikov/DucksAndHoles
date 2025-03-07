using UnityEngine;

public class LvlChooser : MonoBehaviour
{
    [SerializeField] private PhoneInputData phoneInputData;
    private Transform goose;
    [SerializeField] private MoveObjects moveObjects;
    [SerializeField] private GameManager gameManager;

    [SerializeField] private AudioSource audioSourcePop;

    private bool active;
    private int chosenId;
    private int progress;

    public void Init(Transform _goose){
        progress = PlayerPrefs.GetInt("LvlsCompleted", 0);
        goose = _goose;
        active = true;
    }

    void OnEnable(){
        phoneInputData.OnStartTouch += Tap;
    }
    void OnDisable(){
        phoneInputData.OnEndTouch -= Tap;
    }

    void Tap(Vector2 touchPos){
        if (!active) return;
        RaycastHit hit;
        Ray ray = Camera.main.ScreenPointToRay(touchPos);
        if (Physics.Raycast(ray, out hit)) {
            if (hit.collider.TryGetComponent<LvlHole>(out LvlHole lvlHole)){
                audioSourcePop.Play();
                if (lvlHole.GetID() > progress) return;
                chosenId = lvlHole.GetID();
                moveObjects.AddObjToMove(goose, 0.2f, hit.transform.position, goose.rotation, LoadLvl);
                active = false;
            }
        }
    }

    void LoadLvl(){
        gameManager.GenerateLvl(chosenId);
    }

}
