using UnityEngine;

public class Bubble : MonoBehaviour, ITappable
{
    [SerializeField] private int HP = 2;
    [SerializeField] private float healTime = 0.25f;
    private int maxHP;
    [SerializeField] private ParticleSystem particles;
    [SerializeField] private Collider collider;
    [SerializeField] private Animator animator;
    [SerializeField] private AudioSource audioSource;
    [SerializeField] private AudioClip[] tapPopClips;
    private bool popped;

    void Start(){
        maxHP = HP;
    }

    public void Tapped()
    {
        HP--;
        if (popped || HP > 0){
            if (!popped){
                audioSource.clip = tapPopClips[0];
                audioSource.Play();
                animator.SetTrigger("Tapped");
            }
            CancelInvoke("HealHP");
            InvokeRepeating("HealHP", healTime, healTime);
            return;
        }
        popped = true;
        
        audioSource.clip = tapPopClips[1];
        audioSource.Play();
        particles.Play(true);
        animator.SetTrigger("Pop");
        collider.enabled = false;
        Invoke("HideMe", 2f);
    }

    void HealHP(){
        HP++;
        if (HP >= maxHP){
            HP = maxHP;
            CancelInvoke("HealHP");
        }
    }

    void HideMe(){
        gameObject.SetActive(false);
    }

}
