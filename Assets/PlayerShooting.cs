using UnityEngine;
using System.Collections;

public class PlayerShooting : MonoBehaviour
{

    //public ParticleSystem muzzleFlash;
    Animator anim;
    //public GameObject impactPrefab;

    GameObject[] impacts;
    int currentImpact = 0;
    int maxImpacts = 5;

	public ParticleEmitter muzzleFlash;

    bool shooting = false;
    bool isAiming = false;

    // Use this for initialization
    void Start()
    {

        //impacts = new GameObject[maxImpacts];
        //for (int i = 0; i < maxImpacts; i++)
        //    impacts[i] = (GameObject)Instantiate(impactPrefab);
		muzzleFlash.emit=false;
        anim = GetComponent<Animator>();
        Debug.Log(anim.GetBool("isAiming"));
    }

    // Update is called once per frame
    void Update()
    {
        isAiming = Input.GetKey(KeyCode.Mouse1);
        anim.SetBool("isAiming", isAiming);

        if (Input.GetKeyDown(KeyCode.Mouse0) && !Input.GetKey(KeyCode.LeftShift))
        {
           
            //muzzleFlash.Play();
            if (isAiming)
                anim.SetTrigger("aimedFire");
            else
                anim.SetTrigger("blindFire");
			muzzleFlash.Emit ();
            shooting = true;
        }

    }

    void FixedUpdate()
    {
        if (shooting)
        {
            shooting = false;

            RaycastHit hit;

            if (Physics.Raycast(transform.position, transform.forward, out hit, 50f))
            {
                if (hit.transform.tag == "Enemy")
                    Destroy(hit.transform.gameObject);

                impacts[currentImpact].transform.position = hit.point;
                impacts[currentImpact].GetComponent<ParticleSystem>().Play();

                if (++currentImpact >= maxImpacts)
                    currentImpact = 0;
            }
        }
    }
}