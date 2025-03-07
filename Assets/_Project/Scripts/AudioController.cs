using System.Collections.Generic;
using UnityEngine;

public class AudioController : MonoBehaviour
{
    private Transform playerTransform;
    [SerializeField] private float nearRadius = 5f;
    [SerializeField] private float farRadius = 20f;
    [SerializeField] private AnimationCurve volumeCurve = AnimationCurve.Linear(0, 1, 1, 0);
    private List<AudioSource> audioSources = new List<AudioSource>();
    private bool started;

    public void Init(Transform player){
        audioSources.Clear();
        GameObject[] audioObjects = GameObject.FindGameObjectsWithTag("DynamicSound");
        for(int i = 0; i < audioObjects.Length; i++) audioSources.Add(audioObjects[i].GetComponent<AudioSource>());
        playerTransform = player;
        started = true;
    }

    void Update()
    {
        if (!started) return;
        for(int i = 0; i < audioSources.Count; i++){
            if (audioSources[i] == null) continue;

            Vector3 objPos = audioSources[i].transform.position;
            Vector2 audiopos = new Vector2(objPos.x, objPos.z);
            Vector2 playerPos = new Vector2(playerTransform.position.x, playerTransform.position.z);
            float distance = Vector2.Distance(audiopos, playerPos);

            float newVolume = 0f;
            if (distance <= nearRadius) newVolume = 1f;
            else if (distance >= farRadius) newVolume = 0f;
            else
            {
                float t = (distance - nearRadius) / (farRadius - nearRadius);
                newVolume = volumeCurve.Evaluate(t);
            }

            audioSources[i].volume = newVolume;
        }
    }

    void OnDrawGizmosSelected()
    {
        if (playerTransform == null)return;
        Gizmos.color = Color.green;
        Gizmos.DrawWireSphere(playerTransform.position, nearRadius);
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(playerTransform.position, farRadius);
    }
}
