using UnityEngine;

public class Bubble : MonoBehaviour, ITappable
{
    [SerializeField] private int HP = 2;
    [SerializeField] private float healTime = 0.25f;
    private int maxHP;
    [SerializeField] private ParticleSystem particles;
    [SerializeField] private Collider collider;
    [SerializeField] private Animator animator;
    private bool popped;

    void Start(){
        maxHP = HP;
    }

    public void Tapped()
    {
        HP--;
        if (popped || HP > 0){
            if (!popped) animator.SetTrigger("Tapped");
            CancelInvoke("HealHP");
            InvokeRepeating("HealHP", healTime, healTime);
            return;
        }
        popped = true;

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
