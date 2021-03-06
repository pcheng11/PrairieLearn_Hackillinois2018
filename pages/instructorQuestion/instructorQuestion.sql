-- BLOCK assessment_question_stats
SELECT
    aset.name || ' ' || a.number || ': ' || title AS title,
    ci.short_name AS course_title,
    a.id AS assessment_id,
    a.type AS type,
    a.course_instance_id,
    aset.color,
    (aset.abbreviation || a.number) as label,
    admin_assessment_question_number(aq.id) as number,
    aq.*
FROM
    assessment_questions AS aq
    JOIN assessments AS a ON (a.id = aq.assessment_id)
    JOIN assessment_sets AS aset ON (aset.id = a.assessment_set_id)
    JOIN course_instances AS ci ON (ci.id = a.course_instance_id)
WHERE
    aq.question_id=$question_id
    AND aq.deleted_at IS NULL
GROUP BY
    a.id,
    aq.id,
    aset.id,
    ci.id
ORDER BY
    admin_assessment_question_number(aq.id);


-- BLOCK get_topics

SELECT
coalesce(jsonb_agg(to_jsonb(topic.*) ORDER BY topic.number), '[]'::jsonb) AS topics
FROM
    topics AS topic
WHERE
    topic.course_id = $course_id

-- BLOCK get_tags

SELECT
    coalesce(jsonb_agg(to_jsonb(tag.*) ORDER BY tag.number), '[]'::jsonb) AS tags
    FROM
        tags AS tag
    WHERE
        tag.course_id = $course_id

-- BLOCK get_types
SELECT unnest(enum_range(NULL::enum_question_type)) AS types

-- BLOCK insert_question_tag
INSERT INTO question_tags
    (question_id, tag_id, number)
VALUES
    ($question_id, $tag_id, $tag_number)
ON CONFLICT
(question_id, tag_id) DO
UPDATE
SET
    number = EXCLUDED.number
RETURNING id;

-- BLOCK get_number_of_tags
SELECT 
    number AS tag_number
    FROM 
        tags
    WHERE 
        id = $tag_id


-- BLOCK edit_topic
UPDATE questions 
SET topic_id =
(SELECT id FROM topics WHERE name = $topic_value)
WHERE id = $question_id


-- BLOCK edit_type
UPDATE questions 
SET type = $type_value
WHERE id = $question_id

-- BLOCK edit_qid
UPDATE questions 
SET qid = $qid_value
WHERE id = $question_id

-- BLOCK edit_title
UPDATE questions
SET title = $title_value
WHERE id = $question_id