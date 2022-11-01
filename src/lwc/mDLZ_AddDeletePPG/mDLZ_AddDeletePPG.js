import {api, LightningElement, track, wire} from 'lwc';

//APEX-Methods
import insertTProds from '@salesforce/apex/MDLZ_AddPPG.insertTProds';
import getProducts from '@salesforce/apex/MDLZ_AddPPG.getProducts';
import {ShowToastEvent} from "lightning/platformShowToastEvent";

export default class LwcDynamicRecordRowsCreation extends LightningElement {

@track listOfTProds;
@api recordId;
@track PPGOptions;
@track l_All_Types;
@track subPPGOptions;
@track allSubPPG;
@track prodList;
@track PPGList = []; 
result;

connectedCallback() {
this.initData();
}

initData() {
let listOfTProds = [];
this.createRow(listOfTProds);
this.listOfTProds = listOfTProds;
}

createRow(listOfTProds) {
let prod = {};
if(listOfTProds.length > 0) {
    prod.index = listOfTProds[listOfTProds.length - 1].index + 1;
} else {
    prod.index = 1;
}
//this.subPPGOptions = null;
prod.MDLZ_PPG__c = null;
prod.MDLZ_SubPPG__c = null;
prod.MDLZ_Price__c = null;
prod.MDLZ_Location__c = null;
prod.ACCL__Tactic__c = null;
listOfTProds.push(prod);
}




handleInputChange(event) {
let index = event.target.dataset.id;
let fieldName = event.target.name;
let value = event.target.value;
var recId =this.recordId;
var tName = 'ACCL__Tactic__c';
//var pName = 'ACCL__Product__c';
// var prodId= 'a2n8G0000008X8tQAE';
for(let i = 0; i < this.listOfTProds.length; i++) {
    if(this.listOfTProds[i].index === parseInt(index)) {
        this.listOfTProds[i][fieldName] = value;
        this.listOfTProds[i][tName] = recId;
        // this.listOfTProds[i][pName] = prodId;
    }
}
}

//This method is used to set Sub PPG based on PPG value
handleProdChange(event){    
try{ 
var value = event.target.value;        
var allSubPPGs = this.l_All_Types; 
let subOptions = []; 
var PPGOpt =value;
this.PPG = event.target.value;        
for (var key in allSubPPGs[PPGOpt]) {
    // Here key will have index of list of records starting from 0,1,2,....
    subOptions.push({ label: allSubPPGs[PPGOpt][key], value: allSubPPGs[PPGOpt][key]});       
    // Here Name and Id are fields from Product list.
}
this.subPPGOptions = subOptions;
this.handleInputChange(event);
}catch (error) {
console.error('check error here', error);
}
    //= event.target.value; 
}

@wire(getProducts, {})
wiredProducts2({ error, data }) { 
if (data) {
    try {
        this.l_All_Types = data; 
        let options = [];                 
        for (var key in data) {               
            // Here key will have index of list of records starting from 0,1,2,....
            options.push({ label: key, value: key}); 
            // Here Name and Id are fields from Product list.
        }
        this.PPGOptions = options;                 
    } catch (error) {
        console.error('check error here', error);
    }
} else if (error) {
    console.error('check error here', error);
}
}

createTProds(event) {
    var isValid = true;
    for(let i = 0; i < this.listOfTProds.length; i++){
        let dataId = this.listOfTProds[i].index;
        let inputs=this.template.querySelectorAll(`[data-id="${dataId}"]`);
        for(let index = 0; index < inputs.length; index++){
            const input = inputs[index];
            if(input.name != 'MDLZ_SubPPG__c' && (!input.value || !input.checkValidity())){
                console.log(input.name);
                isValid = false;
            }
        }
    }
    if(isValid){
        let ev = new CustomEvent('ppgsave');   
        insertTProds({
            jsonOfListOfTPRoducts : JSON.stringify(this.listOfTProds)
        }) 
            .then(data => {  console.log( JSON.stringify( "Apex update result: " + data ) );        
               // this.initData();
                this.result = JSON.stringify(data);
                this.dispatchEvent(ev);  
                if(this.result.includes('Success')){
                let event = new ShowToastEvent({
                    message: "PPG successfully created!",
                    variant: "success",
                    duration: 1000
                });this.dispatchEvent(event);
            }else{
                    let event =  new ShowToastEvent({
                        title: 'Error updating or refreshing records',
                        message: 'Tactic Product insert failed.',
                        variant: 'error'                   
                    });this.dispatchEvent(event);
                }
                
            })
            .catch(error => {
                console.log( 'Error is ' + JSON.stringify( error ) );
                this.errorMessage =JSON.stringify( error );
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating or refreshing records',
                    message: this.errorMessage,
                    variant: 'error'
                })
            );
            });
    } else {
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Error updating or refreshing records",
                message: "Please fill all the required fields and check all the validations",
                variant: "error"
            })
        );
    }
      
}

}