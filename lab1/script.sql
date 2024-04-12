DO $$
DECLARE
    current_user_name text;
    target_user_name text := 's311817';
    table_number INT := 1;
    table_record RECORD;
BEGIN
    SELECT current_user INTO current_user_name;
    RAISE NOTICE 'Текущий пользователь: %', current_user_name;
    RAISE NOTICE 'Кому выдаем права доступа: %', target_user_name;
    RAISE NOTICE 'No.  Имя таблицы';
    RAISE NOTICE '--- -----------------';
    
    FOR table_record IN
        SELECT table_name
        FROM information_schema.table_privileges
        WHERE grantee = current_user AND is_grantable = 'YES'
        GROUP BY table_name
    LOOP
        RAISE NOTICE '%    %', LPAD(table_number::text, 2), table_record.table_name;
        table_number := table_number + 1;
    END LOOP;
END 
$$ LANGUAGE plpgsql;
