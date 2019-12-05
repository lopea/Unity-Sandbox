using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BitDepth : MonoBehaviour
{
    Material mat; //Material added to screen texture
    
    [SerializeField]
    [Range(2,256)]
    int Depth = 256; //color depth of each pixel 

    // Start is called before the first frame update
    void Start()
    {
      //create material for bit depth shader
      mat = new Material(Shader.Find("Lopea/BitDepth"));    
    }

    void OnRenderImage(RenderTexture source, RenderTexture dest)
    {
      mat.SetFloat("_Depth",Depth);
      Graphics.Blit(source,dest,mat);
    }
}
