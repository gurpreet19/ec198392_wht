CREATE OR REPLACE PACKAGE BODY EcDp_Balance IS
/****************************************************************
** Package        :  EcDp_Balance, body part
**
** $Revision: 1.2 $
**
** Purpose        :  Provide special functions on Balance. Use EcDp_Objects for basis functions
**
** Documentation  :  www.energy-components.com
**
** Created  : 27.06.2006  Stian Skj?tad
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
   1.1      27.06.06 SSK      Modified function GetBetweenNodeDirAc swithced prefix on return value for the two if-sentences to
                              return positive/negative prefix in accordance with HCB documentation for Release 9.0.1
                              Currently used functions/procedures:
                              GetBetweenNodeDirAc
   1.2      30.06.06 SSK      Modified function GetStreamDir swithced prefix on return value for the two if-sentences to
                              return positive/negative prefix in accordance with HCB documentation for Release 9.0.1
                              Currently used functions/procedures:
                              GetBetweenNodeDirAc
                              GetStreamDir
   1.3      03.06.06 SSK      Removed most of the functions that are not in use anymore
*******************************************************************************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetStreamDir
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetStreamDir(
   p_balance_id VARCHAR2,
   p_object_id  VARCHAR2, -- Stream Item Id
   p_daytime    DATE,
   p_node_id    VARCHAR2
) RETURN NUMBER
--</EC-DOC>

IS

lv2_stream_id stream.object_id%TYPE;
lv2_at_node_id node.object_id%TYPE;

cursor c_node (pc_stream_id VARCHAR2, pc_node_id VARCHAR2) is
  SELECT  si.object_id
  FROM    stream_item si, stream_item_version siv
  WHERE   si.object_id = siv.object_id
    AND siv.daytime = (SELECT max(daytime) FROM stream_item_version WHERE object_id = siv.object_id AND daytime <= p_daytime)
    AND (p_daytime >= Nvl(si.start_date,p_daytime-1) AND p_daytime < Nvl(si.end_date, p_daytime+1))
  AND EXISTS
  (  select 'x'
     from   stream s_si
     where  (p_daytime >= Nvl(s_si.start_date,p_daytime-1) AND p_daytime < Nvl(s_si.end_date, p_daytime+1))
     AND    s_si.object_id = pc_stream_id
     AND    si.stream_id = s_si.object_id)
  AND EXISTS
  (  select 'x'
     from   node n_si
     where  (p_daytime >= Nvl(n_si.start_date,p_daytime-1) AND p_daytime < Nvl(n_si.end_date, p_daytime+1))
     and    n_si.object_id = pc_node_id
     and    DECODE(ec_stream_item_version.value_point(siv.object_id, siv.daytime, '<=')
            ,'FROM_NODE', ec_strm_version.from_node_id(ec_stream_item.stream_id(siv.object_id), siv.daytime, '<=')
            ,'TO_NODE', ec_strm_version.to_node_id(ec_stream_item.stream_id(siv.object_id), siv.daytime, '<=') ) = n_si.object_id)
  AND EXISTS
  (   SELECT 'x'
      FROM  balance_setup b_si
      WHERE p_daytime >= Nvl(b_si.daytime,p_daytime-1)
      AND   b_si.object_id = p_balance_id
      AND   b_si.stream_item_id = si.object_id);

BEGIN

     IF p_node_id IS NULL THEN RETURN NULL; END IF; -- result is unknown

     -- find stream associated with stream item
     lv2_stream_id := ec_stream_item.stream_id(p_object_id);

     IF (ec_stream_item_version.value_point(p_object_id, p_daytime, '<=') = 'FROM_NODE') THEN
         lv2_at_node_id := ec_strm_version.from_node_id(ec_stream_item.stream_id(p_object_id), p_daytime, '<=');
     ELSIF (ec_stream_item_version.value_point(p_object_id, p_daytime, '<=') = 'TO_NODE') THEN
         lv2_at_node_id := ec_strm_version.to_node_id(ec_stream_item.stream_id(p_object_id), p_daytime, '<=');
     END IF;

     -- check from / to compared with node to determine direction
    IF lv2_at_node_id <> p_node_id THEN

        FOR NodeCur IN c_node (lv2_stream_id, p_node_id) LOOP

           RETURN NULL;

        END LOOP;

     END IF;

     IF Nvl(ec_strm_version.from_node_id(lv2_stream_id, p_daytime, '<=' ),'XXX') = p_node_id THEN

        RETURN 1;

     ELSIF Nvl(ec_strm_version.to_node_id(lv2_stream_id, p_daytime, '<=' ),'XXX') = p_node_id THEN

        RETURN -1;

     ELSE

        RETURN NULL;

     END IF;

END GetStreamDir;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetBetweenNodeDirAc
-- Description    : Returns stream direction (1 or -1) between two nodes (actual values),
--                  if there exist more than one stream items between these two nodes with
--                  the same stream
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetBetweenNodeDirAc(
   p_balance_id        VARCHAR2,
   p_object_id         VARCHAR2,
   p_daytime           DATE,
   p_from_node_id      VARCHAR2,
   p_to_node_id        VARCHAR2
)
RETURN NUMBER
--</EC-DOC>
IS

cursor c_bet_node (pc_stream_id VARCHAR2, pc_at_node_id VARCHAR2, pc_from_node_id VARCHAR2, pc_to_node_id VARCHAR2) is
  SELECT  si.object_id
  FROM    stream_item si
          ,balance_setup b_si
          ,node n_si
          ,strm_version s_si
          ,node fn_s
          ,node tn_s
          ,stim_mth_actual a
  WHERE   a.object_id = si.object_id
  AND     a.daytime = p_daytime
  AND     (p_daytime >= Nvl(si.start_date,p_daytime-1) AND p_daytime < Nvl(si.end_date, p_daytime+1))
  -- balance -> stream_item
  AND     b_si.stream_item_id = si.object_id
  AND     b_si.object_id = p_balance_id
  AND     p_daytime >= Nvl(b_si.daytime,p_daytime-1)
  -- node -> stream_item (at_node)
  AND     DECODE(ec_stream_item_version.value_point(si.object_id, si.start_date, '<=')
          ,'FROM_NODE',ec_strm_version.from_node_id(ec_stream_item.stream_id(si.object_id), p_daytime, '<=')
          ,'TO_NODE',ec_strm_version.to_node_id(ec_stream_item.stream_id(si.object_id), p_daytime, '<='))
          = pc_at_node_id
  AND     n_si.object_id = pc_at_node_id
  AND     (p_daytime >= Nvl(n_si.start_date,p_daytime-1) AND p_daytime < Nvl(n_si.end_date, p_daytime+1))
  -- stream -> stream_item
  AND     s_si.object_id = si.stream_id
  AND     s_si.object_id = pc_stream_id
  AND     s_si.daytime = (SELECT max(daytime) FROM strm_version WHERE object_id = s_si.object_id AND daytime <= p_daytime)
  -- node -> stream (from_node)
  AND     fn_s.object_id = s_si.from_node_id
  AND     fn_s.object_id = pc_from_node_id
  AND     (p_daytime >= Nvl(fn_s.start_date,p_daytime-1) AND p_daytime < Nvl(fn_s.end_date, p_daytime+1))
  -- node -> stream (to_node)
  AND     tn_s.object_id = s_si.to_node_id
  AND     tn_s.object_id = pc_to_node_id
  AND     (p_daytime >= Nvl(tn_s.start_date,p_daytime-1) AND p_daytime < Nvl(tn_s.end_date, p_daytime+1))
;

lv2_stream_id VARCHAR2(32);
lv2_from_node_id VARCHAR2(32);
lv2_to_node_id VARCHAR2(32);
lv2_at_node_id VARCHAR2(32);

BEGIN

  IF Nvl(p_from_node_id,'XXX') = Nvl(p_to_node_id,'XXX') THEN

     RETURN NULL; -- do not include in any between balance

  END IF;


  -- determine which stream
  lv2_stream_id := ec_stream_item.stream_id(p_object_id);

  -- determine which at node (value point node)
     IF (ec_stream_item_version.value_point(p_object_id, p_daytime, '<=') = 'FROM_NODE') THEN
         lv2_at_node_id := ec_strm_version.from_node_id(ec_stream_item.stream_id(p_object_id), p_daytime, '<=');
     ELSIF (ec_stream_item_version.value_point(p_object_id, p_daytime, '<=') = 'TO_NODE') THEN
         lv2_at_node_id := ec_strm_version.to_node_id(ec_stream_item.stream_id(p_object_id), p_daytime, '<=');
     END IF;

  -- determine whether stream goes between from / to node
  lv2_from_node_id := ec_strm_version.from_node_id(lv2_stream_id, p_daytime, '<=');
  lv2_to_node_id := ec_strm_version.to_node_id(lv2_stream_id, p_daytime, '<=');

  -- determine relation between node1 and between node2 where at node = between node1
  IF lv2_from_node_id = p_from_node_id AND lv2_to_node_id = p_to_node_id AND lv2_at_node_id = p_from_node_id THEN

      -- return -1 if
      FOR NodeCur IN c_bet_node (lv2_stream_id, lv2_to_node_id, lv2_from_node_id, lv2_to_node_id) LOOP

         RETURN -1;

      END LOOP;

      FOR NodeCur IN c_bet_node (lv2_stream_id, lv2_to_node_id, lv2_to_node_id, lv2_from_node_id) LOOP

         RETURN -1;

      END LOOP;

      RETURN NULL;

  -- determine relation between node1 and between node2 where at node = between node2
  ELSIF lv2_from_node_id = p_from_node_id AND lv2_to_node_id = p_to_node_id AND lv2_at_node_id = p_to_node_id THEN

      -- return 1 if
      FOR NodeCur IN c_bet_node (lv2_stream_id, lv2_from_node_id, lv2_from_node_id, lv2_to_node_id) LOOP

         RETURN 1;

      END LOOP;

      FOR NodeCur IN c_bet_node (lv2_stream_id, lv2_to_node_id, lv2_to_node_id, lv2_from_node_id) LOOP

         RETURN 1;

      END LOOP;

      RETURN NULL;

   ELSE

      RETURN NULL;

   END IF;

END GetBetweenNodeDirAc;

END EcDp_Balance;