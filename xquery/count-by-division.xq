declare default element namespace "http://eprints.org/ep2/data/2.0";
declare variable $DIVISIONS external;
declare variable $TITLE external;

let $search_divisions := tokenize($DIVISIONS, "\s+")
return
    <data>
        <com>TITLE: {$TITLE}</com>
        <div>DIVISIONS: {$DIVISIONS}</div>
        {
            for $div in $search_divisions
                let $count := count(//eprint[.//divisions/item = $div])
                return
                    <count div="{$div}">
                    {$count}
                    </count>
        }
    </data>
