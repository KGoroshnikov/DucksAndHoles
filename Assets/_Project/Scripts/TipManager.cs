using UnityEngine;

public class TipManager : MonoBehaviour
{
    [SerializeField] private PhoneInputData phoneInputData;
    [SerializeField] private Animator[] lvlAnimators;
    [SerializeField] private RectTransform rectTransform;
    [SerializeField] private Canvas canvas;
    [SerializeField] private RectTransform canvasRect;
    private Transform player;
    private int currentLevel;
    private int stage;
    private Vector3 neutralEuler;
    private Transform lvl6Ball;
    private bool active;

    void OnEnable(){
        phoneInputData.OnStartTouch += TapStarted;
        phoneInputData.OnEndTouch += TapEnded;
    }
     void OnDisable(){
        phoneInputData.OnStartTouch -= TapStarted;
        phoneInputData.OnEndTouch -= TapEnded;
    }

    public void TapStarted(Vector2 touchPos){
        if (!active) return;
        neutralEuler = Funcs.GyroToUnity(phoneInputData.GetAttitude()).eulerAngles;
        if (currentLevel == 1){
            stage = 1;
            UpdateLvl1();
        }
    }
    public void TapEnded(Vector2 touchPos){
        if (!active) return;
        if (currentLevel == 1){
            stage = 0;
            UpdateLvl1();
        }
    }

    public void SetLevel(int lvl){
        active = true;
        currentLevel = lvl;
        if (currentLevel == 1) UpdateLvl1();
        else if (currentLevel == 6) UpdateLvl6();
    }

    public void SetupLvl6(Transform ball, Transform goose){
        player = goose;
        lvl6Ball = ball;
    }

    public void HideTips(){
        active = false;
        for(int i = 0; i < lvlAnimators.Length; i++)
            lvlAnimators[i].gameObject.SetActive(false);
    }

    void Update()
    {
        if (currentLevel == 6) UpdateTipPosition();
        if (currentLevel != 1 || stage != 1 || !active) return;
        Vector3 currentEuler = Funcs.GyroToUnity(phoneInputData.GetAttitude()).eulerAngles;
        float deltaX = Mathf.DeltaAngle(neutralEuler.x, currentEuler.x);
        float deltaY = -Mathf.DeltaAngle(neutralEuler.z, currentEuler.z);
        if ((Mathf.Abs(deltaX) >= 8 || Mathf.Abs(deltaY) >= 8) && stage != 2){
            stage = 2;
            UpdateLvl1();
        }
    }

    void UpdateTipPosition()
    {
        if (lvl6Ball == null) return;
        if (!UpdateLvl6()) return;

        Vector3 screenPoint = Camera.main.WorldToScreenPoint(lvl6Ball.position);
        bool isVisible = screenPoint.z > 0;
        if (!isVisible) return;
        RectTransformUtility.ScreenPointToLocalPointInRectangle(
            canvasRect,
            screenPoint,
            canvas.renderMode == RenderMode.ScreenSpaceOverlay ? null : canvas.worldCamera,
            out Vector2 localPosition);
        rectTransform.localPosition = localPosition;
    }

    void UpdateLvl1(){
        // stages: 0 - no tap, 1 - tapped, 2 - phone rotated
        lvlAnimators[currentLevel - 1].gameObject.SetActive(true);
        if (stage == 0) lvlAnimators[0].SetTrigger("FingerTip");
        else if (stage == 1) lvlAnimators[0].SetTrigger("PhoneTip");
        else lvlAnimators[currentLevel - 1].gameObject.SetActive(false);
    }

    bool UpdateLvl6(){
        if (currentLevel == 0) return false;
        if (Vector3.Distance(player.position, lvl6Ball.position) > .1f){
            if (lvlAnimators[currentLevel - 1].gameObject.activeSelf)
                lvlAnimators[currentLevel - 1].gameObject.SetActive(false);
            return false;
        }
        else if (!lvlAnimators[currentLevel - 1].gameObject.activeSelf)
            lvlAnimators[currentLevel - 1].gameObject.SetActive(true);
        return true;
    }
}
