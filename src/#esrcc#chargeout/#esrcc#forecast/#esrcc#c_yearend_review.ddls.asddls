@AbapCatalog.extensibility.extensible: true
@EndUserText.label: 'Year End Review'
@ObjectModel.query.implementedBy : 'ABAP:/ESRCC/CL_C_YEAREND'
@Metadata.allowExtensions: true
@UI: {
  headerInfo: {
    typeName: 'Year End Charge-Out',
    typeNamePlural: 'Year End Charge-Outs',
    title: {
      type: #STANDARD,
      value: 'Receivingentity'
    },    
    description.value: 'legalentitydescription'
  },
presentationVariant: [{ sortOrder: [
                                      { by: 'sysid' },
                                      { by: 'Legalentity' },
                                      { by: 'ccode' },
                                      { by: 'Costobject' },
                                      { by: 'Costcenter' },
                                      { by: 'ServiceProduct' },
                                      { by: 'Receivingentity' },
                                      { by: 'ReceiverCompanyCode' },
                                      { by: 'ReceiverCostObject' },
                                      { by: 'ReceiverCostCenter' }
                                      ] }]
}
define root custom entity /ESRCC/C_YEAREND_REVIEW
{
      @UI.facet                   : [
          {
           id                     : 'general',
           type                   : #COLLECTION,
           label                  : 'Charge-Out Details',
           purpose                : #STANDARD,
           position               : 10
          },
         {
          label                   : 'Service Provider Details',
          targetQualifier         : 'OrgData',
          type                    : #FIELDGROUP_REFERENCE,
          purpose                 : #STANDARD,
          parentId                : 'general'
        },        
        {type                     : #DATAPOINT_REFERENCE,
         targetQualifier          : 'srvprd',
          purpose                 : #HEADER
        },
        {type                     : #DATAPOINT_REFERENCE,
         targetQualifier          : 'ytd',
          purpose                 : #HEADER
        },
        {type                     : #DATAPOINT_REFERENCE,
         targetQualifier          : 'forecast',
          purpose                 : #HEADER
        },
        {type                     : #DATAPOINT_REFERENCE,
         targetQualifier          : 'yearend',
          purpose                 : #HEADER
        }
         ]
      @UI.lineItem                : [
      {  position                 : 280 ,
      importance                  : #MEDIUM,
      label                       : '',
      cssDefault                  :{width: '5rem'}
      } ]
      @UI.fieldGroup              : [
      {
      importance                  : #HIGH,
      position                    : 5 ,
      qualifier                   : 'OrgData'
      } ]
      @Consumption.valueHelpDefinition: [{distinctValues: true },{ entity: { name: '/ESRCC/I_RYEAR', element: 'ryear' }}]
      @UI.selectionField          : [{ position: 10 }]
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory:true
  key ryear                       : /esrcc/ryear;

      @UI.lineItem                : [ {
//            position              : 282 ,
//            importance            : #MEDIUM,
//            label                 : '',
//            cssDefault            :{width: '5rem'},
            hidden                : true
          } ]
      @UI.fieldGroup              : [
      {
      importance                  : #HIGH,
      position                    : 20 ,
      qualifier                   : 'OrgData'
      } ]
      @UI.selectionField          : [{ position: 20 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_POPER', element: 'Poper' }}]
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory:true
      @EndUserText.label          : 'Year-To-Date Period'
      @UI.textArrangement: #TEXT_ONLY
  key Refpoper                    : /esrcc/poper;

      @UI.lineItem                : [ {
      position                    : 10 ,
      importance                  : #MEDIUM,
      label                       : '',
      cssDefault                  :{width: '5rem'}
      } ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_SystemInformation_F4', element: 'SystemId' } }]
  key sysid                       : /esrcc/sysid;

      @UI.lineItem                : [ {
      position                    : 20 ,
      importance                  : #MEDIUM,
      label                       : '',
      cssDefault                  :{width: '15rem'}
      } ]
      @UI.fieldGroup              : [
      {
      importance                  : #HIGH,
      position                    : 20 ,
      qualifier                   : 'OrgData'
      } ]
      @ObjectModel.text.element   : [ 'legalentitydescription' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_LegalEntity_F4', element: 'Legalentity' } }]
      @UI.selectionField          : [{ position: 30 }]
      @UI.textArrangement         : #TEXT_LAST
  key Legalentity                 : /esrcc/legalentity;

      @UI.lineItem                : [ {
      position                    : 30 ,
      importance                  : #MEDIUM,
      label                       : '',
      cssDefault                  :{width: '15rem'}
      } ]
      @UI.fieldGroup              : [
      {
      importance                  : #HIGH,
      position                    : 30 ,
      qualifier                   : 'OrgData'
      } ]
      @ObjectModel.text.element   : [ 'ccodedescription' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COMPANYCODES_PR_F4', element: 'Ccode' }}]
      //                                           additionalBinding: [{ element: 'Legalentity', localElement: 'Legalentity' }]}]
      @UI.selectionField          : [{ position: 40 }]
      @UI.textArrangement         : #TEXT_LAST
  key ccode                       : /esrcc/ccode_de;

      @UI.lineItem                : [ {
      position                    : 40 ,
      importance                  : #MEDIUM,
      label                       : '',
      cssDefault                  :{width: '10rem'}
      } ]
      @UI.fieldGroup              : [
      {
      importance                  : #HIGH,
      position                    : 40 ,
      qualifier                   : 'OrgData'
      } ]
      @ObjectModel.text.element   : [ 'costobjectdescription' ]
      @UI.selectionField          : [{ position: 50 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTOBJECTS', element: 'Costobject' }}]
      @UI.textArrangement         : #TEXT_LAST
  key Costobject                  : /esrcc/costobject_de;

      @UI.lineItem                : [ {
      position                    : 50 ,
      importance                  : #MEDIUM,
      label                       : '',
      cssDefault                  :{width: '10rem'}
      } ]
      @UI.fieldGroup              : [
      {
      importance                  : #HIGH,
      position                    : 50 ,
      qualifier                   : 'OrgData'
      } ]
      @ObjectModel.text.element   : [ 'costcenterdescription' ]
      @UI.selectionField          : [{ position: 60 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSCEN_F4', element: 'Costcenter' }}]
      //                                           additionalBinding: [{ element: 'Costobject', localElement: 'Costobject'}]}]
      @UI.textArrangement         : #TEXT_LAST
  key Costcenter                  : /esrcc/costcenter;

      @UI.lineItem                : [ {
        position                  : 60 ,
        importance                : #MEDIUM,
        label                     : '',
        cssDefault                :{width: '15rem'}
      } ]
      @UI.fieldGroup              : [
      {
        importance                : #HIGH,
        position                  : 60 ,
        qualifier                 : 'OrgData'
      } ]
      @UI.selectionField          : [{ position: 70 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_PROFITCENTER_F4', element: 'ProfitCenter' }}]
      @ObjectModel.text.element   : [ 'profitcenterdescription' ]
      @UI.textArrangement         : #TEXT_LAST
  key Profitcenter                : /esrcc/profit_center;

      @UI.lineItem                : [ {
        position                  : 70 ,
        importance                : #MEDIUM,
        label                     : '',
        cssDefault                :{width: '15rem'}
      } ]
      @UI.fieldGroup              : [
      {
        importance                : #HIGH,
        position                  : 70 ,
        qualifier                 : 'OrgData'
      } ]
      @UI.selectionField          : [{ position: 80 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_BUSINESSDIV_F4', element: 'BusinessDivision' }}]
      @ObjectModel.text.element   : [ 'businessdescription' ]
      @UI.textArrangement         : #TEXT_LAST
  key Businessdivision            : /esrcc/businessdivision;

      @UI.lineItem                : [ {
       position                   : 80 ,
       importance                 : #MEDIUM,
       label                      : '',
       cssDefault                 :{width: '15rem'}
      } ]
      @UI.fieldGroup              : [
      {
        importance                : #HIGH,
        position                  : 80 ,
        qualifier                 : 'OrgData'
      } ]
      @UI.selectionField          : [{ position: 90 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_FunctionalArea_F4', element: 'FunctionalArea' }}]
      @ObjectModel.text.element   : [ 'functionalareadescription' ]
      @UI.textArrangement         : #TEXT_LAST
  key FunctionalArea              : /esrcc/functional_area;

      @UI.lineItem                : [ {
      position                    : 90 ,
      importance                  : #MEDIUM,
      label                       : '',
      cssDefault                  :{width: '15rem'}
      } ]
      @ObjectModel.text.element   : [ 'Serviceproductdescription' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_SERVICEPRODUCT_F4', element: 'ServiceProduct' }}]
      //                                       additionalBinding: [{ element: 'OECD', localElement: 'OECD' }]}]
      @UI.selectionField          : [{ position: 100 }]
      @UI.dataPoint               : { qualifier: 'srvprd' }
      @UI.textArrangement         : #TEXT_LAST
  key ServiceProduct              : /esrcc/srvproduct;

      @UI.lineItem                : [ {
        position                  : 100 ,
        importance                : #MEDIUM,
        label                     : '',
        cssDefault                :{width: '15rem'}
      } ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_OECD', element: 'OECD' }}]
      @UI.selectionField          : [{ position: 110 }]
      @UI.fieldGroup              : [
      {
        importance                : #HIGH,
        position                  : 100,
        qualifier                 : 'OrgData'
      } ]
      @ObjectModel.text.element   : [ 'oecdDescription' ]
      @UI.textArrangement         : #TEXT_LAST
  key OECD                        : /esrcc/oecdtpg_de;

      @UI.lineItem                : [ {
       position                   : 110 ,
       importance                 : #MEDIUM,
       label                      : ''

      } ]
      @UI.fieldGroup              : [
      {
        importance                : #HIGH,
        position                  : 110 ,
        qualifier                 : 'OrgData'
      } ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_SERVICETYPE_F4', element: 'ServiceType' }}]
      @UI.selectionField          : [{ position: 120 }]
      @ObjectModel.text.element   : [ 'Servicetypedescription' ]
      @UI.textArrangement         : #TEXT_LAST
  key Servicetype                 : /esrcc/srvtype_de;

      @UI.lineItem                : [ {
        position                  : 120 ,
        importance                : #MEDIUM,
        label                     : ''

      } ]
      @UI.fieldGroup              : [
      {
        importance                : #HIGH,
        position                  : 120 ,
        qualifier                 : 'OrgData'
      } ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_TRANSACTIONGROUP_F4', element: 'Transactiongroup' }}]
      @UI.selectionField          : [{ position: 130 }]
      @ObjectModel.text.element   : [ 'Transactiongroupdescription' ]
      @UI.textArrangement         : #TEXT_LAST
  key Transactiongroup            : /esrcc/tg;

      @UI.lineItem                : [ {
      position                    : 200 ,
      importance                  : #MEDIUM,
      label                       : '',
      cssDefault                  :{width: '5rem'}
      } ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_SystemInformation_F4', element: 'SystemId' } }]
  key ReceiverSysId               : /esrcc/recsysid;

      @UI.lineItem                : [ {
        position                  : 210,
        importance                : #MEDIUM,
        label                     : '',
        cssDefault                :{width: '15rem'}
      } ]
      @ObjectModel.text.element   : [ 'receivingentitydescription' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_RECEIVINGENTITY_F4', element: 'Receivingentity' } }]
      @UI.selectionField          : [{ position: 140 }]
      @UI.textArrangement         : #TEXT_LAST
  key Receivingentity             : /esrcc/receivingntity;

      @UI.lineItem                : [ {
        position                  : 220 ,
        importance                : #MEDIUM,
        label                     : '',
        cssDefault                :{width: '15rem'}
      } ]
      @ObjectModel.text.element   : [ 'RecCcodedescription' ]
      @UI.selectionField          : [{ position: 150 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COMPANYCODES_REC_F4', element: 'Ccode' }}]
      //                                           additionalBinding: [{ element: 'Legalentity', localElement: 'Receivingentity' }]}]
      @UI.textArrangement         : #TEXT_LAST
  key ReceiverCompanyCode         : /esrcc/recccode_de;

      @UI.lineItem                : [ {
        position                  : 230 ,
        importance                : #MEDIUM,
        label                     : '',
        cssDefault                :{width: '10rem'}
      } ]
      @ObjectModel.text.element   : [ 'RecCostObjectdescription' ]
      @UI.selectionField          : [{ position: 160 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTOBJECTS', element: 'Costobject' }}]
      @UI.textArrangement         : #TEXT_LAST
  key ReceiverCostObject          : /esrcc/reccostobject_de;

      @UI.lineItem                : [ {
        position                  : 240 ,
        importance                : #MEDIUM,
        label                     : '',
        cssDefault                :{width: '10rem'}
      } ]
      @ObjectModel.text.element   : [ 'RecCostCenterdescription' ]
      @UI.selectionField          : [{ position: 170 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSCEN_RECEIVER_F4', element: 'Costcenter' }}]
      //                                           additionalBinding: [{ element: 'Costobject', localElement: 'ReceiverCostObject'}]}]
      @UI.textArrangement         : #TEXT_LAST
  key ReceiverCostCenter          : /esrcc/reccostcenter;

      @UI.lineItem                : [ {
        position                  : 999 ,
        importance                : #MEDIUM,
        label                     : '',
        hidden                    : true
      } ]
      @UI.selectionField          : [{ position: 900 }]
      @Consumption.filter.mandatory:true
      @Consumption.filter.selectionType: #SINGLE
      @EndUserText.label          : 'Currency Type'
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_CURR', element: 'Currencytype' }}]
      @Consumption.filter.defaultValue: 'L'
      @ObjectModel.text.element   : [ 'currencytypedescription' ]
      @UI.textArrangement         : #TEXT_LAST
  key Currencytype                : /esrcc/sendercurr;

      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_Currency', element: 'Currency' }} ]
      @EndUserText.label          : 'Currency'
      Currency                    : /esrcc/localcurr;

      @UI.lineItem                : [ {
        position                  : 300 ,
        importance                : #MEDIUM,
        label                     : ''
      } ]
      @UI.dataPoint               : { qualifier: 'ytd', title: 'Year-To-Date' }
      @EndUserText.label          : 'Year-To-Date Amount'
      @Semantics.amount.currencyCode: 'Currency'
      @Aggregation.default        : #SUM
      Ytdamount                   : abap.curr(23,2);

      @UI.lineItem                : [ {
        position                  : 310 ,
        importance                : #MEDIUM,
        label                     : ''
      } ]
      @UI.dataPoint               : { qualifier: 'forecast', title: 'Year-To-Go' }
      @EndUserText.label          : 'Year-To-Go Amount'
      @Semantics.amount.currencyCode: 'Currency'
      @Aggregation.default        : #SUM
      Forecastamount              : abap.curr(23,2);

      @UI.lineItem                : [ {
        position                  : 320 ,
        importance                : #MEDIUM,
        label                     : ''
      } ]
      @UI.dataPoint               : { qualifier: 'yearend', title: 'Year-End' }
      @EndUserText.label          : 'Year-End Amount'
      @Semantics.amount.currencyCode: 'Currency'
      @Aggregation.default        : #SUM
      Yearendamount               : abap.curr(23,2);

      @UI.lineItem                : [ {
       position                   : 999 ,
       importance                 : #MEDIUM
      } ]
      //      @UI.hidden                 : true
      RecCountry                  : land1;
      @UI.lineItem                : [ {
       position                   : 999 ,
       importance                 : #MEDIUM
      } ]
      //      @UI.hidden                 : true
      LECountry                   : land1;
      @UI.hidden                  : true
      legalentitydescription      : /esrcc/description;
      @UI.hidden                  : true
      ccodedescription            : /esrcc/description;
      @UI.hidden                  : true
      costobjectdescription       : /esrcc/description;
      @UI.hidden                  : true
      costcenterdescription       : /esrcc/description;
      @UI.hidden                  : true
      profitcenterdescription     : /esrcc/description;
      @UI.hidden                  : true
      businessdescription         : /esrcc/description;
      @UI.hidden                  : true
      functionalareadescription   : /esrcc/description;
      @UI.hidden                  : true
      Serviceproductdescription   : /esrcc/description;
      @UI.hidden                  : true
      oecdDescription             : /esrcc/description;
      @UI.hidden                  : true
      Servicetypedescription      : /esrcc/description;
      @UI.hidden                  : true
      Transactiongroupdescription : /esrcc/description;
      @UI.hidden                  : true
      receivingentitydescription  : /esrcc/description;
      @UI.hidden                  : true
      RecCcodedescription         : /esrcc/description;
      @UI.hidden                  : true
      RecCostObjectdescription    : /esrcc/description;
      @UI.hidden                  : true
      RecCostCenterdescription    : /esrcc/description;
      @UI.hidden   
      currencytypedescription     : /esrcc/description;  

}
