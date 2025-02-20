using UnityEngine;

public class LvlChooser : MonoBehaviour
{
    [SerializeField] private PhoneInputData phoneInputData;
    private Transform goose;
    [SerializeField] private MoveObjects moveObjects;
    [SerializeField] private GameManager gameManager;

    private bool active;
    private int chosenId;

    public void Init(Transform _goose){
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
                moveObjects.AddObjToMove(goose, 0.2f, hit.transform.position, goose.rotation, LoadLvl);
                active = false;
                chosenId = lvlHole.GetID();
            }
        }
    }

    void LoadLvl(){
        gameManager.GenerateLvl(chosenId);
    }

}
