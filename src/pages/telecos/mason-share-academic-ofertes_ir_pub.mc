<%args>
  $id => undef
</%args>
<%init>
  my @data = ();
  my ($curs,$quad) = $schemaB3->resultset('IrOferta')->get_curs_quad_act();
	my $list = $schemaB3->resultset( "IrOferta" )
	    ->actives->search( {
          estat_candidatura => { 'in' => [1,2,3,4] },
          estat_publicacio => 1,
          curs => $curs,
          quad => $quad,
          titulacio => { -like => "%1280%"} 
      }, { order_by =>{ -desc => ['me.mod']}  });

  $list = $list->search({ 
    idoferta => $id
  }) if $id;

	while (my $n = $list->next) {
		my $tipus = $n->get_tipus_ext;
	  my %h;
    $h{titol}  = $n->titol;
    $h{prof}   = $n->get_nom_professor;
    $h{tipus}  = $tipus;
    $h{idProj} = $n->idoferta;
    $h{data_pub} = $n->data_publicacio ? $n->data_publicacio->ymd : '0000-00-00';
    $h{data_cad} = $n->data_caducitat ? $n->data_caducitat->ymd : '0000-00-00';
    $h{resum} = substr($n->descripcio,0,200).( length($n->descripcio) > 200 ? '...':'');
    $h{curs} = $n->curs;
    $h{quad} = $n->quad;
    if ($id) {
      $h{desc} = $n->descripcio;
      $h{lloc} = $n->lloc_realitzacio;
      $h{email}  = $n->email;
      $h{dep}      = $n->departament ? $n->departament->desc_larga_ang : '';
		  $h{degree}   = $n->get_titulacions_ofertades_str;
      if($n->fitxer) {
        $h{f_enllac} = $n->fitxer->rel_filename;
        $h{f_nom}    = $n->fitxer->nom;
      }
    }
    push @data, \%h;
	}

  my $json = {
		'dades' => \@data,
	  };
  $r->content_type('application/json; charset=iso-8859-1');
  print JSON->new->latin1->encode($json);
</%init>