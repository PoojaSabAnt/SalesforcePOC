import { api, LightningElement, track, wire  } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateTacticProd from '@salesforce/apex/MDLZ_AddPPG.updateTacticProd';
import getProducts from '@salesforce/apex/MDLZ_AddPPG.getProducts';
import deleteProds from '@salesforce/apex/MDLZ_AddPPG.deleteTacticProd';
import getTacticProducts from '@salesforce/apex/MDLZ_AddPPG.getTacticProducts';

export default class MDLZ_TacticsProductView extends LightningElement {
defaultSortDirection = 'asc';
sortDirection = 'asc';
sortedBy;
@track columns = [
    { label: 'PPG', fieldName: 'MDLZ_PPG__c'  },
    { label: 'Sub PPG', fieldName: 'MDLZ_SubPPG__c' },      
    { label: 'SRP', fieldName: 'MDLZ_Price__c' ,type:'currency', required: true, editable: true, 
    typeAttributes: 
    { minimumFractionDigits: 2, maximumFractionDigits: 2},
    cellAttributes: { alignment: 'left' }},
    { label: 'Location', fieldName: 'MDLZ_Location__c' , required: true, editable: true},
    { label: '' ,initialWidth: 50,  type:'button-icon',
    typeAttributes:
    {
        iconName: 'utility:delete',
        name: 'delete',
        iconClass: 'slds-icon-text-error'
    }},
    { label: '' ,initialWidth: 50,  type:'button-icon',
    typeAttributes:
    {   title: 'Save',
        iconName: 'action:approval',
        name: 'save',
        iconClass: 'slds-icon-text-success'
    }}
];
@track prodList;
@track tacticsProdList;
@track l_All_Types;
@track TypeOptions;
@api recordId;
renderInnerTable = false;
wiredRecords;
Successtoast ='Success';
deleteSelectedRow ;
draftValues;
cellChangeAction = false;
rowAction = false
saveEvent;

/*constructor() {
    super();
    window.addEventListener('beforeunload', (event) => {
        // Cancel the event as stated by the standard.
        event.preventDefault();
        // Chrome requires returnValue to be set.
        event.returnValue = 'sample value';
    });
}*/

connectedCallback() {
   // this.tacticsProdList = [];    
    this.initData();
    this.renderInnerTable= false;
    //this.draftValues = null;

    //added event listner to show prompt for any unsaved changes
    window.addEventListener('beforeunload', (event) => {
        if(this.draftValues != null && this.draftValues != undefined){
            // Cancel the event as stated by the standard.
            event.preventDefault();
            // Chrome requires returnValue to be set.
            event.returnValue = 'sample value';
        }
    });
}

disconnectedCallback() {
    window.removeEventListener('beforeunload', (event) => {
        if(this.draftValues != null && this.draftValues != undefined){
            // Cancel the event as stated by the standard.
            event.preventDefault();
            // Chrome requires returnValue to be set.
            event.returnValue = 'sample value';
        }
    });
    console.log("disconnectedCallback executed");
}

initData() {  
    getTacticProducts ({ tacId: this.recordId })
    .then(data => { 
        this.tacticsProdList = data; 
        console.log('***'+ JSON.stringify(this.tacticsProdList ));        
    })
    .catch(error => {
        this.showToast('Error','error','Error');  
    });

}

@wire(getProducts, {})
wiredProducts2({ error, data }) { 
    if (data) {
        try {
            this.l_All_Types = data; 
            let options = [];                 
            for (var key in data) {
                // Here key will have index of list of records starting from 0,1,2,....
                options.push({ label: data[key].MDLZ_PPG__c, value: data[key].Id  }); 
                // Here Name and Id are fields from Product list.
            }
            this.TypeOptions = options;                 
        } catch (error) {
            console.error('check error here', error);
        }
    } else if (error) {
        console.error('check error here', error);
    }
}

addRow(){   
    this.renderInnerTable= true;    
}

removeRow(){
    this.renderInnerTable= false; 
}


handleProdChange(event){
   var value = event.detail.value;   
} 


//Method to save records from inline editing
saveTacPro(event) {
    //const updatedFields = event.detail.draftValues;
    const tacRec = event.detail.row;   
    updateTacticProd( {tacRec:tacRec , data: this.draftValues , recordId: this.recordId } )
    .then( result => {
        this.draftValues = null;
        this.cellChangeAction = false;
        this.rowAction = false;
        this.connectedCallback();
        if(result.Success){
            this.showToast('PPG updated successfully.','Success',this.Successtoast);
        } if(result.ApexError){
            this.showToast('PPG cannot be updated.',Error, result.ApexError);
        }
    })
    .catch(error => {
        this.draftValues = null;
        this.cellChangeAction = false;
        this.rowAction = false;
        this.connectedCallback();
        this.showToast('PPG cannot be updated.','error','Error');      
    });
}

showToast(messg, ttl ,Vari){
    this.dispatchEvent(
        new ShowToastEvent({
            title: ttl,
            message: messg,
            variant: Vari,
            duration: 1000
        })
    );
   
}

//Method to verify cell change
handleCellChange(event){
    this.draftValues = this.template.querySelector('lightning-datatable').draftValues;
    this.connectedCallback();
    this.cellChangeAction = true;
    if(this.cellChangeAction == true && this.rowAction == true){
		//Calling the save method when save button is clicked and cell change is completed
        this.handleSave();
    }
}

handleRowAction(event) {
    this.draftValues = this.template.querySelector('lightning-datatable').draftValues;
    this.connectedCallback();
    const tacRec = event.detail.row;
    if (event.detail.action.name === 'delete') {
        this.draftValues = null;
        this.connectedCallback();
        const tactic = event.detail.row.Id;
        deleteProds ({ tacRec: tacRec ,  recordId: this.recordId})
        .then(result => {  this.connectedCallback();
            if(result.Success){
                this.showToast('PPG Deleted', '',this.Successtoast);
            } if(result.ApexError){
                this.showToast('PPG cannot be deleted.','' ,result.ApexError);
            }
    })
    .catch(error => {this.connectedCallback();
        this.showToast('Internal error.','Error','Error');  
    }); 
    //this.connectedCallback();
    }
    if (event.detail.action.name === 'save') { 
        this.rowAction = true;
		//saving the current event value
        this.saveEvent = event;
        if(this.cellChangeAction == true && this.rowAction == true){
			//Calling the save method when save button is clicked and cell change is completed
            this.handleSave();
        }
        /*if(this.draftValues.length >1){ 
            this.showToast('Only 1 PPG can be edited/Saved.','Error','Error'); 
            this.connectedCallback();
        }else{
            //checking if price value is valid, if not showing the error
            this.saveTacPro(event);
            /*if(this.draftValues1[0] == undefined || this.countDecimals(this.draftValues1[0].MDLZ_Price__c) > 2){
                this.showToast('Price can be upto 2 decimal places.','Error','Error');  
            } else {
                this.saveTacPro(event);
            }*/
        //}
    }
}

//save method
handleSave(){
    this.draftValues = this.template.querySelector('lightning-datatable').draftValues;
    if(this.draftValues.length >1){ 
        this.showToast('Only 1 PPG can be edited/Saved.','Error','Error'); 
        this.connectedCallback();
    }else{
        this.saveTacPro(this.saveEvent);
    }
}

//Method to count the no. of decimals for validation
/*countDecimals(value) {

    value = Number(value.replace(/[^0-9.-]+/g,""));
    
    if (Math.floor(value) === value) return 0;

    var str = value.toString();
    if (str.indexOf(".") !== -1 && str.indexOf("-") !== -1) {
        return str.split("-")[1] || 0;
    } else if (str.indexOf(".") !== -1) {
        return str.split(".")[1].length || 0;
    }
    return str.split("-")[1] || 0;
}*/

}