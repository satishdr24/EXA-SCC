@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Hierarchy projection for Appl Logs'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S
}
@Metadata.allowExtensions: true
@UI: {
    headerInfo: {
        typeName: 'Message',
        typeNamePlural: 'Messages'
    },
    presentationVariant: [{
        sortOrder: [{
            by: 'CreatedAt',
            direction: #DESC
        }],
//        {
//            by: 'SubApplication',
//            direction: #ASC
//        },
//        {
//            by: 'SerialNumber',
//            direction: #ASC
//        },
//        {
//            by: 'CreatedAt',
//            direction: #ASC
//        }],
        visualizations: [{
            type: #AS_LINEITEM
        }]
    }]
}
define root view entity /ESRCC/C_ApplicationLogsHier
  provider contract transactional_query
  as projection on /ESRCC/I_ApplicationLogsHierF
{
  key     Hid,
          ParentHid,
          HierarchyLevel,
          DrilldownState,
          @ObjectModel.text.element: ['ApplicationDescription']
          Application,
          @ObjectModel.text.element: ['SubApplicationDescription']
          SubApplication,
          RunNumber,
          JobName,
          JobCount,
          ReportingYear,
          PeriodFrom,
          PeriodTo,
          PlanningVersion,
          @ObjectModel.text.element: ['LegalEntityDescription']
          LegalEntity,
          @ObjectModel.text.element: ['SystemIdDescription']
          SystemId,
          @ObjectModel.text.element: ['CompanyCodeDescription']
          CompanyCode,
          CreatedBy,
          SerialNumber,
          MessageId,
          MessageNumber,
          MessageType,
          MessageTypeCriticality,
          MessageV1,
          MessageV2,
          MessageV3,
          MessageV4,
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:/ESRCC/CL_VE_MESSAGE_TEXT'
  virtual MessageText : abap.char(255),
          CreatedAt,
          LogHeaderUuid,
          Ryear,
          Poper,
          Fplv,
          Sysid,
          InvalidRecordLegalentity,
          Ccode,
          Belnr,
          Buzei,
          Costobject,
          Costcenter,
          Costelement,
          Businessdivision,
          Profitcenter,
          FunctionalArea,
          @Semantics.amount.currencyCode : 'Localcurr'
          Hsl,
          Localcurr,
          @Semantics.amount.currencyCode : 'Groupcurr'
          Ksl,
          Groupcurr,
          Vendor,
          Postingtype,
          Costind,
          Usagecal,
          ObjectType,
          ObjectNumber,
          Ledger,
          RRMatter,
          Material,
          ReferenceBelnr,
          PostingKey,
          PostingDate,
          PartnerObjectNo,
          PartnerProfitCenter,
          LineCount,
          RootUUID,
          @Semantics.text: true
          ApplicationDescription,
          @Semantics.text: true
          SubApplicationDescription,
          @Semantics.text: true
          SystemIdDescription,
          @Semantics.text: true
          CompanyCodeDescription,
          @Semantics.text: true
          LegalEntityDescription


}
