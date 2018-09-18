CREATE OR REPLACE PACKAGE EcDp_BPM_EC_Event_Inbound IS


    SUBTYPE T_STATE IS NUMBER;
    gv2_state_new CONSTANT T_STATE := 0;
    gv2_state_processing CONSTANT T_STATE := 1;
    gv2_state_processed_successful CONSTANT T_STATE := 2;
    gv2_state_processed_failed CONSTANT T_STATE := 3;

    -----------------------------------------------------------------------
    -- Select a limited amount of events whose id is ordered by time
    -- It returns a single column cursor of selected event ids.
    ----+----------------------------------+-------------------------------
    FUNCTION pop_pending_event(p_max_count NUMBER DEFAULT 1)
    RETURN SYS_REFCURSOR;

    -----------------------------------------------------------------------
    -- Add a general event to the event queue.
    -- Attributes are specified by parameter "attributes".
    ----+----------------------------------+-------------------------------
    FUNCTION add_event (
        p_source                           VARCHAR2
       ,p_type                             NUMBER
       ,p_attributes                       IN OUT NOCOPY T_BPM_TABLE_T_EVENT_ATTRIBUTE
       )
    RETURN NUMBER;

    -----------------------------------------------------------------------
    -- Add a ec generic event to the event queue.
    -- calling add_event() procedure.
    -- Attributes: NAME, User-defined attributes
    --             specified by parameter "attributes".
    ----+----------------------------------+-------------------------------
    FUNCTION on_generic_event (
      p_name                              VARCHAR2
     ,p_source                            VARCHAR2
     ,p_attributes                        IN OUT NOCOPY T_BPM_TABLE_T_EVENT_ATTRIBUTE
     )
    RETURN NUMBER;

    -----------------------------------------------------------------------
    -- Add a dataset source updated event to the event queue by
    -- calling add_event() procedure.
    -- Attributes: DATASET_ID, UPDATED_SOURCE_TYPE,
    --             UPDATED_SOURCE_ID, UPDATED_SOURCE_DATASET_ID.
    ----+----------------------------------+-------------------------------
    FUNCTION on_dataset_source_updated (
      p_dataset                            VARCHAR2
     ,p_dataset_type                       VARCHAR2
     ,p_source                             VARCHAR2
     ,p_source_type                        VARCHAR2
     ,p_source_id                          VARCHAR2
     ,p_source_dataset                     VARCHAR2
     ,p_source_dataset_type                VARCHAR2
     )
     RETURN NUMBER;

    -----------------------------------------------------------------------
    -- Add a dataset state updated event to the event queue by
    -- calling add_event() procedure.
    -- Attributes: DATASET_ID, OLD_STATE, NEW_STATE
    ----+----------------------------------+-------------------------------
    FUNCTION on_dataset_state_updated (
      p_dataset                            VARCHAR2
     ,p_dataset_type                       VARCHAR2
     ,p_old_state                          VARCHAR2
     ,p_new_state                          VARCHAR2
     ,p_source                             VARCHAR2
     )
    RETURN NUMBER;

    -----------------------------------------------------------------------
    -- Add a dataset deleted event to the event queue using add_event().
    -- Attributes: DATASET_ID.
    ----+----------------------------------+-------------------------------
    FUNCTION on_dataset_deleted (
      p_dataset                            VARCHAR2
     ,p_dataset_type                       VARCHAR2
     ,p_source                             VARCHAR2
     )
    RETURN NUMBER;

    -----------------------------------------------------------------------
    -- Add a dataset updated event to the event queue using add_event().
    -- Attributes: DATASET_ID, UPDATED_SOURCE_DATASET_ID.
    ----+----------------------------------+-------------------------------
    FUNCTION on_dataset_updated (
      p_dataset                            VARCHAR2
     ,p_dataset_type                       VARCHAR2
     ,p_attribute_name                     VARCHAR2
     ,p_source                             VARCHAR2
     )
    RETURN NUMBER;

    -----------------------------------------------------------------------
    -- Clean up event queue (BPM_EC_EVENT_INBOUND table).
    -- Archive the handled events in BPM_EC_EVENT_ARCHIVE table.
    -- Return the number of archived events of the current call.
    ----+----------------------------------+-------------------------------
    FUNCTION clean_up
    RETURN NUMBER;


END EcDp_BPM_EC_Event_Inbound;
