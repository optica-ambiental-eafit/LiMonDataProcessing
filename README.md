# LiMon_4DAIR_Data_Processing_Algorithms
<div style="text-align: justify"> Here are found the data processing algorithms related to LiMon and the technical requirements for their correct execution. The objective of this project is to retrieve aerosol optical properties such as backscattering and extinction coefficients and linear depolarization ratios. This project hosts the processing codes developed until 2022-11. </div>


# Table of contents
1. [Overview of the information flux for the LiMon data inversion algorithms](#overview)
2. [Overview of the software project built in MATLAB](#overviewcodes)
3. [1st and 2nd step: data reading and preprocessing](#first_sec)
    1. [Sub paragraph](#subparagraph1)
4. [3rd step: Klett - Fernald - Sasano Method (KFS)](#third)
5. [4th step: depolarization calibration](#fourth)


## Overview of the information flux for the LiMon data inversion algorithms <a name="overview"></a>

<img src="https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/Flujo_Lidar_KFS.svg" 
        align="center"
     	alt="https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/Flujo_Lidar_KFS.svg" 
        width="700" 
        height="180" 
        style="display: block; margin: 0 auto" />

In the first step the root folder for storing raw signal is defined 

## Overview of the software project built in MATLAB <a name="overviewcodes"></a>




Before stating the codes flow, it is mandatory to describe the input files. These are binary files provided by the Licel acquisition system installed on LiMon and in order to process it, a conversion to .TXT format is required and done by Licel software "Advanced Viewer". Then, the resulting file will have the following structure:
<img src="https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/files_description.PNG" 
        align="center"
     	alt="https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/files_description.PNG" 
        width="750" 
        height="350" 
        style="display: block; margin: 0 auto" />
	
The codes presented in the following flow diagram are saved in this project and are thought to be as autonomous as possible, being developed based on functions that ease the reading of the programs and its execution by the researcher. The built functions are:

- telecover_obtention_profile.m: brief explanation of the function
- profile_plots.m: brief explanation of the function
- open_files.m: brief explanation of the function
- optical_products.m: brief explanation of the function 
- calibration_products.m: brief explanation of the function


<img src="https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/Flujo_Lidar_codes.svg" 
        align="center"
     	alt="https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/Flujo_Lidar_codes.svg" 
        width="950" 
        height="350" 
        style="display: block; margin: 0 auto" />




## 1st and 2nd step: data reading and preprocessing <a name="title1"></a>

![](https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/Procesamiento%20diagrama%20de%20flujo_PRE.svg)

	
### Sub paragraph <a name="subparagraph1"></a>
This is a sub paragraph, formatted in heading 3 style

## 3rd step: Klett - Fernald - Sasano Method (KFS) <a name="title2"></a>


<img src="https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/Procesamiento%20diagrama%20de%20flujo_KFS.svg"
        alt="https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/Procesamiento%20diagrama%20de%20flujo_KFS.svg"
        width="800" 
        height="600" 
        style="display: block; margin: 0 auto" />

Textico:
**The Cauchy-Schwarz Inequality**

$$\left( \sum_{k=1}^n a_k b_k \right)^2 \leq \left( \sum_{k=1}^n a_k^2 \right) \left( \sum_{k=1}^n b_k^2 \right)$$


## 4th step: depolarization calibration <a name="title3"></a>


------------


------------



# LiMon Hardware



![](https://img.shields.io/github/stars/pandao/editor.md.svg) ![](https://img.shields.io/github/forks/pandao/editor.md.svg) ![](https://img.shields.io/github/tag/pandao/editor.md.svg) ![](https://img.shields.io/github/release/pandao/editor.md.svg) ![](https://img.shields.io/github/issues/pandao/editor.md.svg) ![](https://img.shields.io/bower/v/editor.md.svg)




# 4th step: depolarization calibration

Textico

----

~~Strikethrough~~ <s>Strikethrough (when enable html tag decode.)</s>
*Italic*      _Italic_
**Emphasis**  __Emphasis__
***Emphasis Italic*** ___Emphasis Italic___

Superscript: X<sub>2</sub>，Subscript: O<sup>2</sup>

**Abbreviation(link HTML abbr tag)**

The <abbr title="Hyper Text Markup Language">HTML</abbr> specification is maintained by the <abbr title="World Wide Web Consortium">W3C</abbr>.

###Blockquotes

> Blockquotes

Paragraphs and Line Breaks
                    
> "Blockquotes Blockquotes", [Link](http://localhost/)。

###Links

[Links](http://localhost/)

[Links with title](http://localhost/ "link title")

`<link>` : <https://github.com>

[Reference link][id/name] 

[id/name]: http://link-url/

GFM a-tail link @pandao

###Code Blocks (multi-language) & highlighting

####Inline code

`$ npm install marked`

####Code Blocks (Indented style)

Indented 4 spaces, like `<pre>` (Preformatted Text).

    <?php
        echo "Hello world!";
    ?>
    
Code Blocks (Preformatted text):

    | First Header  | Second Header |
    | ------------- | ------------- |
    | Content Cell  | Content Cell  |
    | Content Cell  | Content Cell  |

####Javascript　

```javascript
function test(){
	console.log("Hello world!");
}
 
(function(){
    var box = function(){
        return box.fn.init();
    };

    box.prototype = box.fn = {
        init : function(){
            console.log('box.init()');

			return this;
        },

		add : function(str){
			alert("add", str);

			return this;
		},

		remove : function(str){
			alert("remove", str);

			return this;
		}
    };
    
    box.fn.init.prototype = box.fn;
    
    window.box =box;
})();

var testBox = box();
testBox.add("jQuery").remove("jQuery");
```

####HTML code

```html
<!DOCTYPE html>
<html>
    <head>
        <mate charest="utf-8" />
        <title>Hello world!</title>
    </head>
    <body>
        <h1>Hello world!</h1>
    </body>
</html>
```

###Images

Image:

![](https://pandao.github.io/editor.md/examples/images/4.jpg)

> Follow your heart.

![](https://pandao.github.io/editor.md/examples/images/8.jpg)

> 图为：厦门白城沙滩 Xiamen

图片加链接 (Image + Link)：

[![](https://pandao.github.io/editor.md/examples/images/7.jpg)](https://pandao.github.io/editor.md/examples/images/7.jpg "李健首张专辑《似水流年》封面")

> 图为：李健首张专辑《似水流年》封面
                
----

###Lists

####Unordered list (-)

- Item A
- Item B
- Item C
     
####Unordered list (*)

* Item A
* Item B
* Item C

####Unordered list (plus sign and nested)
                
+ Item A
+ Item B
    + Item B 1
    + Item B 2
    + Item B 3
+ Item C
    * Item C 1
    * Item C 2
    * Item C 3

####Ordered list
                
1. Item A
2. Item B
3. Item C
                
----
                    
###Tables
                    
First Header  | Second Header
------------- | -------------
Content Cell  | Content Cell
Content Cell  | Content Cell 

| First Header  | Second Header |
| ------------- | ------------- |
| Content Cell  | Content Cell  |
| Content Cell  | Content Cell  |

| Function name | Description                    |
| ------------- | ------------------------------ |
| `help()`      | Display the help window.       |
| `destroy()`   | **Destroy your computer!**     |

| Item      | Value |
| --------- | -----:|
| Computer  | $1600 |
| Phone     |   $12 |
| Pipe      |    $1 |

| Left-Aligned  | Center Aligned  | Right Aligned |
| :------------ |:---------------:| -----:|
| col 3 is      | some wordy text | $1600 |
| col 2 is      | centered        |   $12 |
| zebra stripes | are neat        |    $1 |
                
----

####HTML entities

&copy; &  &uml; &trade; &iexcl; &pound;
&amp; &lt; &gt; &yen; &euro; &reg; &plusmn; &para; &sect; &brvbar; &macr; &laquo; &middot; 

X&sup2; Y&sup3; &frac34; &frac14;  &times;  &divide;   &raquo;

18&ordm;C  &quot;  &apos;

##Escaping for Special Characters

\*literal asterisks\*

##Markdown extras

###GFM task list

- [x] GFM task list 1
- [x] GFM task list 2
- [ ] GFM task list 3
    - [ ] GFM task list 3-1
    - [ ] GFM task list 3-2
    - [ ] GFM task list 3-3
- [ ] GFM task list 4
    - [ ] GFM task list 4-1
    - [ ] GFM task list 4-2

###Emoji mixed :smiley:

> Blockquotes :star:

####GFM task lists & Emoji & fontAwesome icon emoji & editormd logo emoji :editormd-logo-5x:

- [x] :smiley: @mentions, :smiley: #refs, [links](), **formatting**, and <del>tags</del> supported :editormd-logo:;
- [x] list syntax required (any unordered or ordered list supported) :editormd-logo-3x:;
- [x] [ ] :smiley: this is a complete item :smiley:;
- [ ] []this is an incomplete item [test link](#) :fa-star: @pandao; 
- [ ] [ ]this is an incomplete item :fa-star: :fa-gear:;
    - [ ] :smiley: this is an incomplete item [test link](#) :fa-star: :fa-gear:;
    - [ ] :smiley: this is  :fa-star: :fa-gear: an incomplete item [test link](#);
            
###TeX(LaTeX)
   
$$E=mc^2$$

Inline $$E=mc^2$$ Inline，Inline $$E=mc^2$$ Inline。

$$\(\sqrt{3x-1}+(1+x)^2\)$$
                    
$$\sin(\alpha)^{\theta}=\sum_{i=0}^{n}(x^i + \cos(f))$$
                
###FlowChart

```flow
st=>start: Login
op=>operation: Login operation
cond=>condition: Successful Yes or No?
e=>end: To admin

st->op->cond
cond(yes)->e
cond(no)->op
```

###Sequence Diagram
                    
```seq
Andrew->China: Says Hello 
Note right of China: China thinks\nabout it 
China-->Andrew: How are you? 
Andrew->>China: I am good thanks!
```

###End
