@EndUserText.label: 'Hierarchy'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_Hier1
  as select from /esrcc/hier1
  association        to parent /ESRCC/I_Hier1_S as _HierarchyAll       on $projection.SingletonID = _HierarchyAll.SingletonID
  composition [0..*] of /ESRCC/I_Hier1Text      as _HierarchyText
  association [1..1] to /ESRCC/I_STATUS         as _WorkflowStatusText on _WorkflowStatusText.Status = $projection.WorkflowStatus
{
  key hierarchy                   as Hierarchy,
      workflow_id                 as WorkflowId,
      workflow_status             as WorkflowStatus,
      comment_id                  as CommentId,
      case workflow_status
      -- Red
        when 'R' then 1
        when 'E' then 1

      -- Yellow
        when 'D' then 2
        when 'W' then 2
        when 'P' then 2
        when 'J' then 2
        when 'L' then 2

      -- Green
        when 'A' then 3
        when 'F' then 3
        else 0
      end                         as WorkflowStatusCriticality,
      ''                          as WorkflowInternalStatus,
      cast('' as /esrcc/comment ) as Comments,
      @Semantics.user.createdBy: true
      created_by                  as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                  as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by             as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at             as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at       as LocalLastChangedAt,
      1                           as SingletonID,
      _HierarchyAll,
      _HierarchyText,
      _WorkflowStatusText

}
