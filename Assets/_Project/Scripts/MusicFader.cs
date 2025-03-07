using UnityEngine;

public class MusicFader : MonoBehaviour
{
    private AudioSource currentSource;
    private float fadeTime;
    private float startVolume;
    private float targetVolume;
    private bool fadeStarted;
    private float t;

    public void FadeOutMusic(AudioSource _source, float _fadeTime = 1, float _targetVolume = 0){
        currentSource = _source;
        startVolume = currentSource.volume;
        fadeTime = _fadeTime;
        targetVolume = _targetVolume;
        fadeStarted = true;
        t = 0;
    }

    void Update()
    {
        if (!fadeStarted) return;
        t += Time.deltaTime / fadeTime;
        if (t >= 1){
            t = 1;
            fadeStarted = false;
        }
        currentSource.volume = Mathf.Lerp(startVolume, targetVolume, t);
    }
}
